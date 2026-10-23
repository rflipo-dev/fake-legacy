insert into products (sku, name, category, base_price, sale_price, weight_kg, stock_quantity, reserved_quantity, active, created_at) values
('BKS-1001', 'Clean Code',                  'BOOKS',       32.90, null,   0.600, 50, 0, true,  CURRENT_TIMESTAMP),
('BKS-1002', 'Refactoring',                 'BOOKS',       44.00, null,   0.800, 40, 0, true,  CURRENT_TIMESTAMP),
('BKS-1003', 'Domain-Driven Design',        'BOOKS',       54.50, null,   1.100, 25, 0, true,  CURRENT_TIMESTAMP),
('FOD-2001', 'Organic Coffee 1kg',          'FOOD',        18.90, null,   1.000, 100, 0, true, CURRENT_TIMESTAMP),
('FOD-2002', 'Dark Chocolate Box',          'FOOD',        12.50, null,   0.400, 80, 0, true,  CURRENT_TIMESTAMP),
('FOD-2003', 'Olive Oil 5L',                'FOOD',        39.90, null,   4.800, 30, 0, true,  CURRENT_TIMESTAMP),
('ELC-3001', 'Wireless Mouse',              'ELECTRONICS', 29.90, null,   0.200, 60, 0, true,  CURRENT_TIMESTAMP),
('ELC-3002', 'Mechanical Keyboard',         'ELECTRONICS', 89.00, null,   1.000, 35, 0, true,  CURRENT_TIMESTAMP),
('ELC-3003', '27in Monitor',                'ELECTRONICS', 249.00, null,  6.500, 15, 0, true,  CURRENT_TIMESTAMP),
('ELC-3004', 'Noise Cancelling Headphones', 'ELECTRONICS', 199.00, 149.00, 0.400, 20, 0, true, CURRENT_TIMESTAMP),
('ELC-3005', 'USB-C Hub',                   'ELECTRONICS', 45.00, null,   0.150, 1, 0, true,   CURRENT_TIMESTAMP),
('ELC-9999', 'Discontinued Radio',          'ELECTRONICS', 19.90, null,   0.500, 12, 0, false, CURRENT_TIMESTAMP),
('HOM-4001', 'Desk Lamp',                   'HOME',        34.90, null,   1.200, 45, 0, true,  CURRENT_TIMESTAMP),
('HOM-4002', 'Ergonomic Chair',             'HOME',        329.00, null, 14.000, 10, 0, true,  CURRENT_TIMESTAMP),
('HOM-4003', 'Cast Iron Pan',               'HOME',        59.00, 39.00,  3.200, 22, 0, true,  CURRENT_TIMESTAMP),
('HOM-4004', 'Industrial Workbench',        'HOME',        480.00, null, 45.000, 6, 0, true,   CURRENT_TIMESTAMP),
('HOM-4005', 'Marble Table',                'HOME',        890.00, null, 62.000, 4, 0, true,   CURRENT_TIMESTAMP),
('SPT-5001', 'Yoga Mat',                    'SPORT',       24.90, null,   1.500, 70, 0, true,  CURRENT_TIMESTAMP),
('SPT-5002', 'Dumbbell Set',                'SPORT',       79.00, null,  20.000, 18, 0, true,  CURRENT_TIMESTAMP),
('TOY-6001', 'Building Blocks',             'TOYS',        27.50, null,   0.900, 55, 0, true,  CURRENT_TIMESTAMP),
('CLO-7001', 'Rain Jacket',                 'CLOTHING',    69.00, null,   0.700, 40, 0, true,  CURRENT_TIMESTAMP);

insert into promotions (code, promo_type, promo_value, min_order_amount, valid_from, valid_to, max_usage, usage_count, allowed_categories, first_order_only) values
('WELCOME10', 'PERCENT', 10.00, null,  DATEADD('DAY', -365, CURRENT_DATE), DATEADD('DAY', 365, CURRENT_DATE), 1000, 0,  null,    true),
('SAVE5',     'FIXED',    5.00, 30.00, DATEADD('DAY', -365, CURRENT_DATE), DATEADD('DAY', 365, CURRENT_DATE), 1000, 0,  null,    false),
('BOOKS15',   'PERCENT', 15.00, null,  DATEADD('DAY', -365, CURRENT_DATE), DATEADD('DAY', 365, CURRENT_DATE), 1000, 0,  'BOOKS', false),
('OLD20',     'PERCENT', 20.00, null,  DATEADD('DAY', -400, CURRENT_DATE), DATEADD('DAY', -30, CURRENT_DATE), 1000, 0,  null,    false),
('LIMITED',   'PERCENT', 10.00, null,  DATEADD('DAY', -365, CURRENT_DATE), DATEADD('DAY', 365, CURRENT_DATE), 10,   10, null,    false),
('MEGA25',    'PERCENT', 25.00, null,  DATEADD('DAY', -365, CURRENT_DATE), DATEADD('DAY', 365, CURRENT_DATE), 1000, 0,  null,    false);

-- confirmed reservations behind the historical orders of order-service (needed for returns / restocking)
insert into stock_reservations (order_ref, sku, qty, restocked_qty, expires_at, status, created_at) values
('SEED-1001', 'HOM-4002', 2,  0, DATEADD('DAY', -200, CURRENT_TIMESTAMP), 'CONFIRMED', DATEADD('DAY', -200, CURRENT_TIMESTAMP)),
('SEED-1002', 'ELC-3003', 3,  0, DATEADD('DAY', -120, CURRENT_TIMESTAMP), 'CONFIRMED', DATEADD('DAY', -120, CURRENT_TIMESTAMP)),
('SEED-1003', 'ELC-3002', 10, 0, DATEADD('DAY', -60, CURRENT_TIMESTAMP),  'CONFIRMED', DATEADD('DAY', -60, CURRENT_TIMESTAMP)),
('SEED-1004', 'BKS-1001', 2,  0, DATEADD('DAY', -8, CURRENT_TIMESTAMP),   'CONFIRMED', DATEADD('DAY', -8, CURRENT_TIMESTAMP)),
('SEED-1004', 'FOD-2001', 1,  0, DATEADD('DAY', -8, CURRENT_TIMESTAMP),   'CONFIRMED', DATEADD('DAY', -8, CURRENT_TIMESTAMP)),
('SEED-1004', 'ELC-3001', 1,  0, DATEADD('DAY', -8, CURRENT_TIMESTAMP),   'CONFIRMED', DATEADD('DAY', -8, CURRENT_TIMESTAMP)),
('SEED-2001', 'ELC-3002', 4,  0, DATEADD('DAY', -100, CURRENT_TIMESTAMP), 'CONFIRMED', DATEADD('DAY', -100, CURRENT_TIMESTAMP)),
('SEED-2001', 'HOM-4001', 5,  0, DATEADD('DAY', -100, CURRENT_TIMESTAMP), 'CONFIRMED', DATEADD('DAY', -100, CURRENT_TIMESTAMP)),
('SEED-2002', 'TOY-6001', 1,  0, DATEADD('DAY', -25, CURRENT_TIMESTAMP),  'CONFIRMED', DATEADD('DAY', -25, CURRENT_TIMESTAMP)),
('SEED-3000', 'CLO-7001', 1,  0, DATEADD('DAY', -800, CURRENT_TIMESTAMP), 'CONFIRMED', DATEADD('DAY', -800, CURRENT_TIMESTAMP)),
('SEED-3001', 'TOY-6001', 1,  1, DATEADD('DAY', -70, CURRENT_TIMESTAMP),  'CONFIRMED', DATEADD('DAY', -70, CURRENT_TIMESTAMP)),
('SEED-3002', 'SPT-5001', 1,  1, DATEADD('DAY', -50, CURRENT_TIMESTAMP),  'CONFIRMED', DATEADD('DAY', -50, CURRENT_TIMESTAMP)),
('SEED-3003', 'HOM-4001', 1,  1, DATEADD('DAY', -35, CURRENT_TIMESTAMP),  'CONFIRMED', DATEADD('DAY', -35, CURRENT_TIMESTAMP)),
('SEED-3004', 'BKS-1002', 1,  0, DATEADD('DAY', -6, CURRENT_TIMESTAMP),   'CONFIRMED', DATEADD('DAY', -6, CURRENT_TIMESTAMP));
