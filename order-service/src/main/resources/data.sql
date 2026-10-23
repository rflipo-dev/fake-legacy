-- product cache (refreshed from catalog-service by a scheduled job)
insert into product_cache (sku, category, weight_kg, refreshed_at) values
('BKS-1001', 'BOOKS', 0.600, CURRENT_TIMESTAMP),
('BKS-1002', 'BOOKS', 0.800, CURRENT_TIMESTAMP),
('BKS-1003', 'BOOKS', 1.100, CURRENT_TIMESTAMP),
('FOD-2001', 'FOOD', 1.000, CURRENT_TIMESTAMP),
('FOD-2002', 'FOOD', 0.400, CURRENT_TIMESTAMP),
('FOD-2003', 'FOOD', 4.800, CURRENT_TIMESTAMP),
('ELC-3001', 'ELECTRONICS', 0.200, CURRENT_TIMESTAMP),
('ELC-3002', 'ELECTRONICS', 1.000, CURRENT_TIMESTAMP),
('ELC-3003', 'ELECTRONICS', 6.500, CURRENT_TIMESTAMP),
('ELC-3004', 'ELECTRONICS', 0.400, CURRENT_TIMESTAMP),
('ELC-3005', 'ELECTRONICS', 0.150, CURRENT_TIMESTAMP),
('ELC-9999', 'ELECTRONICS', 0.500, CURRENT_TIMESTAMP),
('HOM-4001', 'HOME', 1.200, CURRENT_TIMESTAMP),
('HOM-4002', 'HOME', 14.000, CURRENT_TIMESTAMP),
('HOM-4003', 'HOME', 3.200, CURRENT_TIMESTAMP),
('HOM-4004', 'HOME', 45.000, CURRENT_TIMESTAMP),
('HOM-4005', 'HOME', 62.000, CURRENT_TIMESTAMP),
('SPT-5001', 'SPORT', 1.500, CURRENT_TIMESTAMP),
('SPT-5002', 'SPORT', 20.000, CURRENT_TIMESTAMP),
('TOY-6001', 'TOYS', 0.900, CURRENT_TIMESTAMP),
('CLO-7001', 'CLOTHING', 0.700, CURRENT_TIMESTAMP);

-- historical orders. Insertion order gives the ids:
-- 1..4 customer 1 (GOLD), 5..6 customer 2 (SILVER), 7..11 customer 3 (STANDARD, returns habit)
insert into orders (reference, customer_id, status, b2b, tier_at_checkout, shipping_method, shipping_country,
    goods_ht, goods_ttc, shipping_ttc, total_ttc, discount_cap_applied, promo_code, redeemed_points, earned_points,
    payment_method, paid_amount, refunded_amount, created_at, expires_at, paid_at, shipped_at, delivered_at, legacy_ref, migration_flag) values
('SEED-1001', 1, 'DELIVERED', false, 'STANDARD', 'STANDARD', 'FR', 658.00, 789.60, 0.00, 789.60, false, null, 0, 658,
    'CARD', 789.60, null, DATEADD('DAY', -200, CURRENT_TIMESTAMP), null, DATEADD('DAY', -200, CURRENT_TIMESTAMP), DATEADD('DAY', -198, CURRENT_TIMESTAMP), DATEADD('DAY', -195, CURRENT_TIMESTAMP), null, null),
('SEED-1002', 1, 'DELIVERED', false, 'STANDARD', 'STANDARD', 'FR', 747.00, 896.40, 0.00, 896.40, false, null, 0, 747,
    'CARD', 896.40, null, DATEADD('DAY', -120, CURRENT_TIMESTAMP), null, DATEADD('DAY', -120, CURRENT_TIMESTAMP), DATEADD('DAY', -118, CURRENT_TIMESTAMP), DATEADD('DAY', -115, CURRENT_TIMESTAMP), null, null),
('SEED-1003', 1, 'DELIVERED', false, 'STANDARD', 'STANDARD', 'FR', 863.30, 1035.96, 0.00, 1035.96, false, null, 0, 863,
    'CARD', 1035.96, null, DATEADD('DAY', -60, CURRENT_TIMESTAMP), null, DATEADD('DAY', -60, CURRENT_TIMESTAMP), DATEADD('DAY', -58, CURRENT_TIMESTAMP), DATEADD('DAY', -55, CURRENT_TIMESTAMP), null, null),
('SEED-1004', 1, 'DELIVERED', false, 'GOLD', 'STANDARD', 'FR', 103.14, 112.72, 0.00, 112.72, false, null, 0, 103,
    'CARD', 112.72, null, DATEADD('DAY', -8, CURRENT_TIMESTAMP), null, DATEADD('DAY', -8, CURRENT_TIMESTAMP), DATEADD('DAY', -6, CURRENT_TIMESTAMP), DATEADD('DAY', -3, CURRENT_TIMESTAMP), null, null),
('SEED-2001', 2, 'DELIVERED', false, 'STANDARD', 'STANDARD', 'FR', 525.26, 630.31, 0.00, 630.31, false, null, 0, 525,
    'CARD', 630.31, null, DATEADD('DAY', -100, CURRENT_TIMESTAMP), null, DATEADD('DAY', -100, CURRENT_TIMESTAMP), DATEADD('DAY', -98, CURRENT_TIMESTAMP), DATEADD('DAY', -90, CURRENT_TIMESTAMP), null, null),
('SEED-2002', 2, 'DELIVERED', false, 'SILVER', 'STANDARD', 'FR', 26.12, 31.34, 4.90, 36.24, false, null, 0, 26,
    'CARD', 36.24, null, DATEADD('DAY', -25, CURRENT_TIMESTAMP), null, DATEADD('DAY', -25, CURRENT_TIMESTAMP), DATEADD('DAY', -23, CURRENT_TIMESTAMP), DATEADD('DAY', -20, CURRENT_TIMESTAMP), null, null),
('SEED-3000', 3, 'DELIVERED', false, 'STANDARD', 'STANDARD', 'FR', 69.00, 82.80, 0.00, 82.80, false, null, 0, 69,
    'CARD', 82.80, null, DATEADD('DAY', -800, CURRENT_TIMESTAMP), null, DATEADD('DAY', -800, CURRENT_TIMESTAMP), DATEADD('DAY', -798, CURRENT_TIMESTAMP), DATEADD('DAY', -795, CURRENT_TIMESTAMP), null, null),
('SEED-3001', 3, 'RETURNED', false, 'STANDARD', 'STANDARD', 'FR', 27.50, 33.00, 4.90, 37.90, false, null, 0, 27,
    'CARD', 37.90, 33.00, DATEADD('DAY', -70, CURRENT_TIMESTAMP), null, DATEADD('DAY', -70, CURRENT_TIMESTAMP), DATEADD('DAY', -68, CURRENT_TIMESTAMP), DATEADD('DAY', -65, CURRENT_TIMESTAMP), null, null),
('SEED-3002', 3, 'RETURNED', false, 'STANDARD', 'STANDARD', 'FR', 24.90, 29.88, 4.90, 34.78, false, null, 0, 24,
    'CARD', 34.78, 29.88, DATEADD('DAY', -50, CURRENT_TIMESTAMP), null, DATEADD('DAY', -50, CURRENT_TIMESTAMP), DATEADD('DAY', -48, CURRENT_TIMESTAMP), DATEADD('DAY', -45, CURRENT_TIMESTAMP), null, null),
('SEED-3003', 3, 'RETURNED', false, 'STANDARD', 'STANDARD', 'FR', 34.90, 41.88, 4.90, 46.78, false, null, 0, 34,
    'CARD', 46.78, 41.88, DATEADD('DAY', -35, CURRENT_TIMESTAMP), null, DATEADD('DAY', -35, CURRENT_TIMESTAMP), DATEADD('DAY', -33, CURRENT_TIMESTAMP), DATEADD('DAY', -30, CURRENT_TIMESTAMP), null, null),
('SEED-3004', 3, 'DELIVERED', false, 'STANDARD', 'STANDARD', 'FR', 44.00, 46.42, 4.90, 51.32, false, null, 0, 44,
    'CARD', 51.32, null, DATEADD('DAY', -6, CURRENT_TIMESTAMP), null, DATEADD('DAY', -6, CURRENT_TIMESTAMP), DATEADD('DAY', -4, CURRENT_TIMESTAMP), DATEADD('DAY', -2, CURRENT_TIMESTAMP), null, null);

insert into order_lines (order_id, sku, category, quantity, unit_base_price, discount_tier, discount_volume, discount_promo,
    line_ht, vat_rate, line_ttc, on_sale, returned_quantity) values
((select id from orders where reference = 'SEED-1001'), 'HOM-4002', 'HOME', 2, 329.00, 0.00, 0.00, 0.00, 658.00, 0.200, 789.60, false, 0),
((select id from orders where reference = 'SEED-1002'), 'ELC-3003', 'ELECTRONICS', 3, 249.00, 0.00, 0.00, 0.00, 747.00, 0.200, 896.40, false, 0),
((select id from orders where reference = 'SEED-1003'), 'ELC-3002', 'ELECTRONICS', 10, 89.00, 0.00, 26.70, 0.00, 863.30, 0.200, 1035.96, false, 0),
((select id from orders where reference = 'SEED-1004'), 'BKS-1001', 'BOOKS', 2, 32.90, 6.58, 0.00, 0.00, 59.22, 0.055, 62.48, false, 0),
((select id from orders where reference = 'SEED-1004'), 'FOD-2001', 'FOOD', 1, 18.90, 1.89, 0.00, 0.00, 17.01, 0.055, 17.95, false, 0),
((select id from orders where reference = 'SEED-1004'), 'ELC-3001', 'ELECTRONICS', 1, 29.90, 2.99, 0.00, 0.00, 26.91, 0.200, 32.29, false, 0),
((select id from orders where reference = 'SEED-2001'), 'ELC-3002', 'ELECTRONICS', 4, 89.00, 0.00, 0.00, 0.00, 356.00, 0.200, 427.20, false, 0),
((select id from orders where reference = 'SEED-2001'), 'HOM-4001', 'HOME', 5, 34.90, 0.00, 5.24, 0.00, 169.26, 0.200, 203.11, false, 0),
((select id from orders where reference = 'SEED-2002'), 'TOY-6001', 'TOYS', 1, 27.50, 1.38, 0.00, 0.00, 26.12, 0.200, 31.34, false, 0),
((select id from orders where reference = 'SEED-3000'), 'CLO-7001', 'CLOTHING', 1, 69.00, 0.00, 0.00, 0.00, 69.00, 0.200, 82.80, false, 0),
((select id from orders where reference = 'SEED-3001'), 'TOY-6001', 'TOYS', 1, 27.50, 0.00, 0.00, 0.00, 27.50, 0.200, 33.00, false, 1),
((select id from orders where reference = 'SEED-3002'), 'SPT-5001', 'SPORT', 1, 24.90, 0.00, 0.00, 0.00, 24.90, 0.200, 29.88, false, 1),
((select id from orders where reference = 'SEED-3003'), 'HOM-4001', 'HOME', 1, 34.90, 0.00, 0.00, 0.00, 34.90, 0.200, 41.88, false, 1),
((select id from orders where reference = 'SEED-3004'), 'BKS-1002', 'BOOKS', 1, 44.00, 0.00, 0.00, 0.00, 44.00, 0.055, 46.42, false, 0);

-- three returns in the last 90 days for customer 3 (abuse rule)
insert into return_records (order_id, customer_id, goods_ht, goods_ttc, refund_amount, points_restituted, points_reclaimed, items, created_at) values
((select id from orders where reference = 'SEED-3001'), 3, 27.50, 33.00, 33.00, 0, 27, 'TOY-6001:1', DATEADD('DAY', -62, CURRENT_TIMESTAMP)),
((select id from orders where reference = 'SEED-3002'), 3, 24.90, 29.88, 29.88, 0, 24, 'SPT-5001:1', DATEADD('DAY', -42, CURRENT_TIMESTAMP)),
((select id from orders where reference = 'SEED-3003'), 3, 34.90, 41.88, 41.88, 0, 34, 'HOM-4001:1', DATEADD('DAY', -28, CURRENT_TIMESTAMP));
