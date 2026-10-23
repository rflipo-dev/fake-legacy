# Plan – Fake legacy e-commerce (Java / Spring)

## 0. Cadre technique

| Élément | Choix |
|---|---|
| Langage | Java 17 |
| Framework | Spring Boot 3.3.x (web, data-jpa, jdbc, aop, validation) |
| Build | Maven, **3 projets indépendants** (pas de parent commun, pas de lib partagée → duplication volontaire) |
| Base | H2 in-memory, une par service (console H2 activée) |
| Communication | REST synchrone via `RestTemplate` (instancié différemment dans chaque service) |
| Sécurité | Aucune |
| Langue du code | Anglais |
| Lancement | `docker-compose.yml` + Dockerfile multi-stage par service |
| Vérification | Fichiers `.http` (scénarios) + jeux de données seed |
| Tests | Aucun |
| Lombok | Uniquement dans `catalog-service` (getters/setters/constructeurs écrits à la main ailleurs) |
| Bugs | **Aucun** : comportement exact et cohérent, même code laid |
| Code mort | Oui, abondant (voir §4 « Code mort ») |

Arborescence :

```
fake-legacy/
├── catalog-service/     (port 8081)
├── customer-service/    (port 8082)
├── order-service/       (port 8083)
├── http/                (scénarios .http)
└── docker-compose.yml
```

Conventions globales (doivent rester **identiques partout** pour la cohérence, mais sont **dupliquées** dans chaque service) :
- Montants en `BigDecimal`, EUR, arrondi `HALF_UP` à 2 décimales **au niveau de la ligne**.
- Taux de TVA : `FOOD` et `BOOKS` = 5,5 %, autres catégories = 20 %.
- Durée de réservation de stock : 15 min, configurable via la propriété `reservation.ttl-minutes` (lue par catalog **et** order, même valeur injectée par `docker-compose` via `RESERVATION_TTL_MINUTES`). Le TTL `PENDING_REVIEW` (24 h) est configurable via `reservation.review-ttl-minutes`.

---

## 1. Les 3 services et leurs endpoints

### 1.1 `catalog-service` (8081) – Produits, prix, stock, promotions

| # | Endpoint | Description |
|---|---|---|
| C1 | `GET /products?category=&minPrice=&maxPrice=&available=` | Liste filtrée |
| C2 | `GET /products/{sku}?customerId=` | Fiche + `basePrice`, `salePrice`, `customerPrice` (prix HT après remise de tier), `vatRate`, `available` |
| C3 | `POST /products` | Création |
| C4 | `PUT /products/{sku}/price` | Modification `basePrice` et/ou `salePrice` (historisé) |
| C5 | `POST /stock/reserve` | Réserve des quantités pour un `orderRef` (si `orderRef` existe déjà → **prolonge** la réservation, comportement caché) |
| C6 | `POST /stock/release` | Libère la réservation d'un `orderRef` |
| C7 | `POST /stock/confirm` | Transforme la réservation en sortie de stock (au paiement) ; `?restock=true` pour réintégrer du stock (annulation / retour) |
| C8 | `GET /promotions/validate?code=&customerId=&consume=` | Valide un code ; `consume=true` incrémente l'usage (hack legacy) |
| C9 | `POST /promotions` | Création d'une promotion |

Modèle : `Product(sku, name, category, basePrice, salePrice?, weightKg, stockQuantity, reservedQuantity, active, createdAt)`, `PriceHistory`, `StockReservation(orderRef, sku, qty, expiresAt, status)`, `Promotion(code, type PERCENT|FIXED, value, minOrderAmount, validFrom, validTo, maxUsage, usageCount, allowedCategories?, firstOrderOnly)`.

### 1.2 `customer-service` (8082) – Clients, fidélité, encours B2B

| # | Endpoint | Description |
|---|---|---|
| U1 | `POST /customers` | Inscription B2C / B2B |
| U2 | `GET /customers/{id}` | Profil + `tier` recalculé (avec cache maison) |
| U3 | `PUT /customers/{id}/addresses` | Remplace la liste d'adresses |
| U4 | `GET /customers/{id}/loyalty` | Solde de points |
| U5 | `POST /customers/{id}/loyalty/earn` | Crédit de points (points **négatifs acceptés** = reprise, hack legacy) |
| U6 | `POST /customers/{id}/loyalty/redeem` | Utilisation de points (négatif = restitution) |
| U7 | `GET /customers/{id}/credit` | Plafond, encours, disponible |
| U8 | `POST /customers/{id}/credit/consume` | Consommation d'encours (montant négatif = libération) |
| U9 | `POST /customers/{id}/blacklist` | Blocage (`?value=false` pour débloquer) |

Modèle : `Customer(id, email, type B2C|B2B, companyName?, vatNumber?, registeredAt, blacklisted, tierOverride?, loyaltyPoints, creditLimit, creditOutstanding)`, `Address(customerId, country, city, line, defaultShipping)`, `LoyaltyTransaction`.

### 1.3 `order-service` (8083) – Panier, commande, cycle de vie

| # | Endpoint | Description |
|---|---|---|
| O1 | `POST /carts` | Création de panier pour un client |
| O2 | `POST /carts/{id}/items` | Ajout / mise à jour d'une ligne (`qty=0` supprime) |
| O3 | `GET /carts/{id}` | Panier avec totaux estimés |
| O4 | `POST /carts/{id}/checkout` | Body : `shippingMethod`, `promoCode?` → crée la commande |
| O5 | `GET /orders/{id}` | Détail |
| O6 | `POST /orders/{id}/pay` | Body : `method CARD|B2B_CREDIT`, `cardNumber?`, `loyaltyPoints?` |
| O7 | `PUT /orders/{id}/status` | Endpoint « fourre-tout » : `APPROVE`, `REJECT`, `SHIP`, `DELIVER` |
| O8 | `POST /orders/{id}/cancel` | Annulation |
| O9 | `POST /orders/{id}/return` | Retour partiel par lignes `{sku, qty}` |
| O10 | `GET /customers/{id}/orders?stats=` | Historique ; `stats=true` renvoie le CA 12 mois (utilisé pour le tier) – mal placé volontairement |

Modèle : `Cart`, `CartLine`, `Order(status, customerId, tierAtCheckout, shippingMethod, shippingCountry, goodsHt, goodsTtc, shippingTtc, totalTtc, promoCode, redeemedPoints, earnedPoints, paymentMethod, createdAt, paidAt, deliveredAt…)`, `OrderLine(sku, category, qty, unitBasePrice, lineHt, vatRate, lineTtc, onSale, returnedQty)`, `ReturnRecord`, `ProductCache(sku, category, weightKg)`.

### 1.4 Graphe d'appels (circularités volontaires)

```mermaid
flowchart LR
  O[order-service] -->|prix, stock, promo| C[catalog-service]
  O -->|tier, blacklist, adresse, points, encours| U[customer-service]
  C -->|tier pour customerPrice| U
  C -->|nb commandes (promo firstOrderOnly)| O
  U -->|CA 12 mois (tier)| O
```

---

## 2. Règles métier (référentiel unique – doit rester cohérent)

### R1 – Tier client
- CA = somme `goodsHt` des commandes `PAID|SHIPPED|DELIVERED` des 365 derniers jours, moins les montants HT retournés.
- `STANDARD` < 500 €, `SILVER` ≥ 500 €, `GOLD` ≥ 2 000 €.
- Client B2B : au minimum `SILVER`.
- `tierOverride` (si renseigné) prime sur tout.
- Client blacklisté : affiché `STANDARD`.
- Résultat mis en cache 10 min.
- Le tier est **figé** dans la commande au checkout.

### R2 – Calcul du prix (ordre strict)
1. Prix unitaire de référence : `salePrice` si présent (produit « en soldes »), sinon `basePrice`.
2. Remise tier (hors soldes) : SILVER −5 %, GOLD −10 %.
3. Remise volume (hors soldes) : qté ≥ 5 sur une même ligne → −3 % sur la ligne.
4. Code promo (un seul par commande) : uniquement sur lignes non soldées et de catégorie autorisée.
   - `PERCENT` : appliqué à chaque ligne éligible.
   - `FIXED` : réparti au prorata des lignes éligibles, la dernière ligne absorbe l'écart d'arrondi.
5. Plafond : sur les lignes non soldées, remises cumulées (tier + volume + promo) ≤ 30 % de `Σ basePrice × qty`. En cas de dépassement, **seule la remise promo est réduite**.
6. TVA par ligne selon la catégorie, arrondi à la ligne.
7. `goodsTtc = Σ lineTtc`, `totalTtc = goodsTtc + shippingTtc`.

### R3 – Promotions
- Valide si : date dans `[validFrom, validTo]`, `usageCount < maxUsage`, sous-total HT éligible ≥ `minOrderAmount`.
- `firstOrderOnly` : client sans commande hors `CANCELLED|REJECTED|EXPIRED`.
- Usage consommé au checkout, **jamais restitué** (même en cas d'annulation).

### R4 – Livraison
- `STANDARD` 4,90 € TTC, `EXPRESS` 9,90 € TTC.
- `STANDARD` gratuit si `goodsTtc ≥ 50 €` **ou** client GOLD. `EXPRESS` jamais gratuit.
- Article > 30 kg dans la commande → supplément forfaitaire 29,00 € pour tous (GOLD inclus).
- Pays : FR (base), BE/LU (+5,00 €), autre → checkout refusé.
- Pays = adresse `defaultShipping` du client ; pas d'adresse → checkout refusé.
- Livraison TVA 20 % (prix exprimés TTC).

### R5 – Checkout
- Refusé si client blacklisté, panier vide, produit inactif ou stock disponible insuffisant.
- B2B : `goodsHt` ≥ 200 € HT minimum.
- Anti-fraude : `totalTtc > 1 000 €` et client inscrit depuis < 30 jours → `PENDING_REVIEW` (réservation 24 h), sinon `VALIDATED` (réservation 15 min).
- Le panier est vidé et fermé après checkout.

### R6 – Cycle de vie
```
VALIDATED ──pay──> PAID ──SHIP──> SHIPPED ──DELIVER──> DELIVERED ──return (≤14j)──> (RETURNED partiel/total)
PENDING_REVIEW ──APPROVE──> VALIDATED (réservation prolongée de 15 min)
PENDING_REVIEW ──REJECT──> REJECTED (stock libéré)
VALIDATED non payée après 15 min ──> EXPIRED
VALIDATED|PENDING_REVIEW|PAID ──cancel──> CANCELLED
```

### R7 – Paiement
- Uniquement depuis `VALIDATED` ; la réservation doit être active (sinon commande → `EXPIRED`).
- Points : multiples de 100, 100 pts = 5 €, max 50 % de `goodsTtc`, solde suffisant. Interdit pour B2B.
- `CARD` : numéro finissant par `0000` → refus (commande reste `VALIDATED`).
- `B2B_CREDIT` : réservé B2B, `creditLimit − creditOutstanding ≥ montant restant`.
- Au succès : stock confirmé, points gagnés crédités.

### R8 – Fidélité
- `earnedPoints = floor(goodsHt × (1 − redeemedValue / goodsTtc))` (hors livraison, partie payée en points exclue).
- Client B2B : aucun point gagné (ignoré silencieusement côté customer-service).
- Le solde peut devenir négatif après une reprise ; aucun redeem possible tant que solde < montant demandé.

### R9 – Annulation
- Impossible à partir de `SHIPPED`.
- Avant paiement : libération de la réservation.
- Après paiement : remboursement intégral (livraison incluse), points utilisés restitués, points gagnés repris, encours B2B libéré, stock réintégré.

### R10 – Retours
- Uniquement `DELIVERED`, ≤ 14 jours après `deliveredAt`.
- Catégorie `FOOD` non retournable.
- Refusé si le client a ≥ 3 retours sur les 90 derniers jours.
- Ratio `r = returnedGoodsTtc / goodsTtc` : points utilisés restitués `floor(redeemedPoints × r)`, points gagnés repris `floor(earnedPoints × r)`, le reste remboursé sur le moyen de paiement (encours libéré si B2B).
- Livraison jamais remboursée. Stock réintégré.

### R11 – Catalogue
- SKU au format `[A-Z]{3}-\d{4}`, `basePrice > 0`, `weightKg > 0`.
- `category` et `weightKg` **immuables** (garantit la cohérence du cache produit de l'order-service).
- Changement de prix : baisse > 50 % en une opération interdite ; `salePrice < basePrice` obligatoire.
- Réservations expirées libérées par job toutes les minutes.

### R12 – Clients
- Email unique.
- B2B : `companyName` + `vatNumber` (format `FR\d{11}`) obligatoires ; `creditLimit` 5 000 € par défaut (0 pour B2C).
- Max 5 adresses, exactement une `defaultShipping` (tout pays accepté à l'enregistrement – le refus se fait au checkout).

---

## 3. Éparpillement des règles (où chaque règle vit)

> Principe : aucune règle n'est entièrement dans un seul endroit ; plusieurs sont dupliquées (avec les mêmes valeurs).

| Règle | Emplacement(s) volontairement « mal placé(s) » |
|---|---|
| R1 seuils tier | `customer-service` : `TierCalculator` (static) ; CA calculé par **SQL natif** dans `order-service` (O10) ; plancher B2B dans `CustomerRowMapper` ; override + blacklist dans le controller U2 ; cache dans un singleton maison `TierCache.getInstance()` |
| R2.1–2.2 prix + tier | `catalog-service` : `ProductController` (C2) appelle customer et applique la remise ; taux de remise tier **dupliqués** dans `order-service` (`PricingConstants`) pour l'estimation du panier |
| R2.3 volume | `order-service` : `VolumeDiscountStep` (Template Method `AbstractDiscountStep`) |
| R2.4 promo | Validité dans `catalog-service` `PromotionController` (dates) + `PromotionRepository` (requête JPQL sur usage) ; éligibilité catégories/soldes et répartition FIXED dans `order-service` `OrderManager` |
| R2.5 plafond 30 % | `order-service` : **aspect AOP** `DiscountCapAspect` qui modifie le résultat du calculateur |
| R2.6 TVA | `catalog-service` : `Product.getVatRate()` (entité) ; `order-service` : `TaxUtils` static (dupliqué) + `@PrePersist` de `OrderLine` qui calcule `lineTtc` |
| R3 firstOrderOnly | `catalog-service` appelle `order-service` O10 |
| R4 livraison | `order-service` : Strategy `ShippingStrategy` (Standard/Express) ; supplément lourd dans `OrderManager` via `ProductCache` ; surtaxe BE/LU et refus pays dans `CheckoutController` |
| R5 anti-fraude | `order-service` : **aspect** `FraudCheckAspect` autour de `OrderManager.checkout` qui bascule le statut ; blacklist vérifiée dans le controller ; minimum B2B dans `Order.validate()` |
| R6 transitions | Moitié dans l'entité `Order` (`ship()`, `deliver()`), moitié dans `OrderManager` (`if/else` sur string) ; expiration dupliquée : job `catalog` + job `order` (`OrderExpiryJob`, même constante 15 min) |
| R7 paiement | `order-service` : `PaymentService` avec gros `switch` ; règle 50 % points dans `customer-service` U6 ; règle « pas de points B2B » dans `order-service` ; vérif. encours dans `customer-service` U8 |
| R8 points | Formule dans un `@EventListener` `LoyaltyListener` (order) ; exclusion B2B dans le DAO `LoyaltyDao` (customer) |
| R9 annulation | `OrderManager.cancel` (300 lignes) appelle 4 endpoints dans un ordre précis, sans compensation |
| R10 retours | Délai 14 j dans `ReturnController` ; FOOD via `ProductCache` dans `ReturnService` ; abus 3/90 j en requête SQL native ; ratio dans `OrderLine` |
| R11 prix | `PriceHistoryListener` (`@PreUpdate` JPA) qui lève l'exception de baisse > 50 % ; regex SKU dans le controller |
| R12 clients | Validation B2B dans `CustomerController` ; max 5 adresses dans `AddressDao` (JdbcTemplate) |

---

## 4. Styles d'implémentation par service (hétérogènes)

### catalog-service – « Layered classique dégradé »
- Seul service avec Lombok (`@Data`, `@Builder`, `@RequiredArgsConstructor`… utilisés de façon incohérente : certaines classes mixent Lombok et accesseurs manuels).
- Spring Data JPA, entités exposées directement en JSON.
- Logique dans les controllers, `PriceUtils` statique, listeners JPA.
- Exceptions maison → `@ControllerAdvice` partiel (certaines erreurs renvoient 500).
- `RestTemplate` créé en `new` dans le controller.

### customer-service – « Transaction Script »
- **Pas de JPA** : `JdbcTemplate` + `RowMapper`, `schema.sql` manuel.
- Réponses en `Map<String, Object>` construites à la main.
- Erreurs renvoyées en **HTTP 200** avec `{"status":"ERROR","message":...}`.
- Singleton maison (`getInstance()`) pour le cache de tier, pas un bean Spring.

### order-service – « God class + DDD avorté »
- `OrderManager` (> 1 000 lignes) : checkout, paiement partiel, annulation, retours.
- Entité `Order` partiellement riche.
- Patterns : Strategy (livraison), Template Method (remises), Observer (`ApplicationEvent` pour les points), AOP (fraude, plafond).
- `ProductCache` alimenté par `@Scheduled` (5 min) + fallback REST en cas de miss.
- Erreurs : mélange de `null`, `ResponseEntity.badRequest()` et `RuntimeException`.
- `RestTemplate` en bean, URLs en `@Value`.
- `OrderManager` : **> 1 000 lignes** réelles (méthodes longues, `if/else` imbriqués, helpers privés dupliqués, code mort inclus mais pas majoritaire).

### Code mort (tous services)
Contrainte : jamais appelé sur un chemin d'exécution réel, pour ne pas altérer le comportement.
- Méthodes publiques jamais appelées (`recalculateAllPricesLegacy()`, `migrateOldLoyaltyFormat()`, `applyBlackFridayRules()`).
- Feature flags toujours `false` (`legacy.pricing.v1.enabled`, `FeatureFlags.USE_NEW_SHIPPING`) protégeant des branches alternatives.
- Classes entières orphelines (`OrderExporterCsv`, `LegacyPaymentGateway`, `TierCalculatorV2` non branché).
- Champs d'entité / colonnes jamais lus (`legacyRef`, `migrationFlag`).
- Endpoints commentés, blocs `// TODO`, `// FIXME`, `// DO NOT REMOVE - used by batch` (faux), commentaires obsolètes décrivant d'anciennes règles (ex. « free shipping above 40€ ») – sans jamais contredire le code réellement exécuté.
- Enum values inutilisées (`PaymentMethod.CHEQUE`, `OrderStatus.ON_HOLD`).

---

## 5. Données de démo (seed)

**catalog** (`data.sql`) – ~20 produits dont :
- produits FOOD et BOOKS (TVA 5,5 %) ;
- 2 produits soldés ;
- 2 produits lourds (> 30 kg) ;
- 1 produit inactif ;
- 1 produit stock = 1.

Promotions : `WELCOME10` (10 %, firstOrderOnly), `SAVE5` (5 € fixe, min 30 €), `BOOKS15` (15 %, BOOKS seulement), `OLD20` (expirée), `LIMITED` (maxUsage atteint), `MEGA25` (25 % → déclenche le plafond pour GOLD).

**customer** (`CommandLineRunner` – volontairement différent) :

| id | Profil |
|---|---|
| 1 | B2C GOLD (via historique) |
| 2 | B2C SILVER (via historique) |
| 3 | B2C STANDARD ancien |
| 4 | B2C inscrit aujourd'hui (anti-fraude) |
| 5 | B2B avec encours partiellement utilisé |
| 6 | Blacklisté |
| 7 | Adresse en Allemagne (checkout refusé) |
| 8 | Adresse en Belgique |

**order** (`data.sql`) : commandes historiques `DELIVERED` pour donner les tiers des clients 1 et 2, une commande livrée il y a 3 jours (retour possible), une livrée il y a 20 jours (retour refusé), 3 retours récents pour un client (abus).

---

## 6. Scénarios `.http` (vérification manuelle)

1. Prix catalogue pour client GOLD vs STANDARD.
2. Checkout GOLD avec `MEGA25` → plafond 30 %.
3. Panier avec produit lourd → supplément 29 €.
4. Client 4 > 1 000 € → `PENDING_REVIEW` → `APPROVE` → pay.
5. B2B < 200 € HT refusé, puis paiement sur encours.
6. Paiement mixte points + carte, carte refusée (`…0000`).
7. Annulation après paiement → points, stock, encours restitués.
8. Retour partiel, retour FOOD refusé, retour hors délai refusé.
9. Client blacklisté / pays non livrable refusés.
10. Expiration de réservation : lancer avec `RESERVATION_TTL_MINUTES=1`, attendre 1 min, payer → `EXPIRED`.

---

## 7. Étapes de réalisation

1. Squelettes Maven des 3 services + Dockerfiles + `docker-compose.yml`.
2. `customer-service` (aucune dépendance au démarrage, appels sortants tolérants aux pannes de l'order-service).
3. `catalog-service`.
4. `order-service` (le plus gros).
5. Seeds et fichiers `.http`.
6. Vérification : `mvn package` des 3 services, `docker compose up`, exécution des 10 scénarios, contrôle des montants à la main sur 2–3 cas.
