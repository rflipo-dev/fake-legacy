# fake-legacy

Fausse application e-commerce « legacy » (Java 17 / Spring Boot 3.3), volontairement hétérogène : trois services indépendants, du code dupliqué ou mal placé, du code mort. Le comportement, lui, est exact et cohérent. Le détail des choix et des règles métier est dans [PLAN.md](PLAN.md).

## Services

| Service | Port | Rôle | Style |
|---|---|---|---|
| `catalog-service` | 8081 | Produits, prix, stock, promotions | Layered classique, Lombok, JPA |
| `customer-service` | 8082 | Clients, fidélité, encours B2B | Transaction Script, `JdbcTemplate`, erreurs en HTTP 200 |
| `order-service` | 8083 | Panier, commande, paiement, annulation, retours | God class `OrderManager`, AOP, Strategy, Observer |

Chaque service est un projet Maven autonome (pas de parent commun, pas de lib partagée), avec sa base H2 en mémoire. La console H2 est disponible sur `/h2-console` de chaque service.

## Lancement

```bash
docker compose up -d --build
```

Pour tester l'expiration des réservations avec une durée d'une minute (scénario 10) :

```bash
RESERVATION_TTL_MINUTES=1 docker compose up -d --build
```

Sans Docker, dans chaque dossier de service (Java 17+ et Maven requis) :

```bash
mvn package -DskipTests
java -jar target/*.jar
```

Les URLs des autres services se règlent par variables d'environnement (`CATALOG_SERVICE_URL`, `CUSTOMER_SERVICE_URL`, `ORDER_SERVICE_URL`), avec `localhost` comme valeur par défaut.

## Données de démo

- **catalog** : 21 produits (FOOD/BOOKS à TVA 5,5 %, 2 produits soldés, 2 produits lourds, 1 inactif, 1 à stock unique) et les promos `WELCOME10`, `SAVE5`, `BOOKS15`, `OLD20`, `LIMITED`, `MEGA25`.
- **customer** : clients 1 à 8 (GOLD, SILVER, STANDARD ancien, inscrit aujourd'hui, B2B, blacklisté, adresse allemande, adresse belge).
- **order** : commandes historiques qui déterminent les tiers des clients 1 et 2.
  - commande 4 : livrée il y a 3 jours, retour possible ;
  - commande 6 : livrée il y a 20 jours, retour refusé ;
  - commande 11 : client avec 3 retours récents, retour refusé.

Les ids de commandes seedées ne sont valables que sur un démarrage à vide.

## Scénarios

Les fichiers du dossier [http](http) s'utilisent avec l'extension VS Code REST Client (`# @name` pour chaîner les requêtes).

| Fichier | Scénario |
|---|---|
| `01-catalog-prices.http` | Prix catalogue par tier |
| `02-gold-discount-cap.http` | Plafond de remise de 30 % (GOLD + `MEGA25`) |
| `03-heavy-item-surcharge.http` | Supplément article lourd |
| `04-fraud-review.http` | Anti-fraude : `PENDING_REVIEW`, `APPROVE`, paiement |
| `05-b2b-minimum-and-credit.http` | Minimum B2B et paiement sur encours |
| `06-mixed-payment.http` | Points + carte, carte refusée |
| `07-cancel-after-payment.http` | Annulation après paiement |
| `08-returns.http` | Retours : partiel, FOOD, hors délai, abus |
| `09-refused-checkouts.http` | Blacklist, pays non livrable, stock |
| `10-reservation-expiry.http` | Expiration de réservation |
| `11-other-endpoints.http` | Les autres endpoints |
