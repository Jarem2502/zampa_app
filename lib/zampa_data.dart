
class Product {
  final String name;
  final double price;
  final String description;
  final String category;    // 'Bebidas' o 'Alimentos'
  final String subCategory; // Ej: 'Hamburguesas', 'Sándwich', 'Especiales'
  final String imagePath;   

  const Product({
    required this.name,
    required this.price,
    this.description = '',
    required this.category,
    required this.subCategory,
    this.imagePath = 'assets/zampalogo.png', 
  });
}

final List<Product> allProducts = [
  // ==========================================
  //               ALIMENTOS 
  // ==========================================

  // --- SÁNDWICH ---
  Product(
    name: 'Club Sándwich',
    price: 20.90,
    description: 'Pan de molde, lechuga, tomate, filete de pollo, jamón inglés, queso edam, tocino, huevo frito y papas',
    category: 'Alimentos',
    subCategory: 'Sándwich',
  ),
  Product(
    name: 'Sándwich Mixto + Papas',
    price: 9.90,
    description: 'Pan de molde, jamón inglés y queso Edam. Incluye papas.',
    category: 'Alimentos',
    subCategory: 'Sándwich',
  ),
  Product(
    name: 'Sándwich de Pollo Desmenuzado',
    price: 10.90,
    description: 'Pan, lechuga, tomate, pollo desmenuzado y papas a elección.',
    category: 'Alimentos',
    subCategory: 'Sándwich',
  ),
  Product(
    name: 'Choripan + Papas',
    price: 10.90,
    description: 'Pan, chorizo parrillero y papas fritas.',
    category: 'Alimentos',
    subCategory: 'Sándwich',
  ),
  Product(
    name: 'Sándwich de pollo con durazno',
    price: 14.50,
    description: 'Pan, lechuga, pollo desmenuzado, durazno en almibar y papas. -Foto referencial-',
    category: 'Alimentos',
    subCategory: 'Sándwich',
  ),
  Product(
    name: 'Sándwich super mixto',
    price: 11.50,
    description: 'Pan de molde, jamón inglés, queso edam, huevo frito, tocino y papas.',
    category: 'Alimentos',
    subCategory: 'Sándwich',
  ),

  // --- HAMBURGUESAS ---
  Product(
    name: 'Hamburguesa clásica artesanal',
    price: 14.90,
    description: 'Pan hamburguesa, lechuga, tomate, 90gr de hamburguesa de carne y papas.',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),
  Product(
    name: 'Hamburguesa Royal',
    price: 14.50,
    description: 'Pan hamburguesa, lechuga, tomate, hamburguesa de carne, queso edam y huevo frito y papas.',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),
  Product(
    name: 'Hamburguesa de pollo',
    price: 11.90,
    description: 'Pan hamburguesa, lechuga, tomate, hamburguesa de pollo y papas.',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),
  Product(
    name: 'Hamburguesa hawaiana',
    price: 17.00,
    description: 'Pan hamburguesa, lechuga, tomate, hamburguesa de carne, queso edam, jamón inglés, piña en almíbar y papas.',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),
  Product(
    name: 'Hamburguesa cheese',
    price: 15.90,
    description: 'Pan hamburguesa, lechuga, tomate, hamburguesa de carne, doble queso edam y papas.',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),
  Product(
    name: 'Hamburguesa tocino a la BBQ',
    price: 17.00,
    description: 'Pan hamburguesa, lechuga, tomate, hamburguesa de carne, tocino, salsa BBQ y papas',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),
  Product(
    name: 'Hamburguesa a lo pobre',
    price: 16.50,
    description: 'Pan hamburguesa, lechuga, tomate, hamburguesa de carne, huevo frito, plátano frito y papas.',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),
  Product(
    name: 'Hamburguesa parrillera',
    price: 17.00,
    description: 'Pan hamburguesa, lechuga, tomate, hamburguesa de carne, chorizo parrillero, salsa chimichurri y papas.',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),
  Product(
    name: 'Hamburguesa mixta',
    price: 13.90,
    description: 'Pan hamburguesa, lechuga, tomate, hamburguesa de carne, jamón inglés, queso edam y papas.',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),
  Product(
    name: 'Hamburguesa montada',
    price: 15.90,
    description: 'Pan, hamburguesa de carne, lechuga, tomate, huevo frito y papas fritas.',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),
  Product(
    name: 'Zampa hamburguesa',
    price: 19.90,
    description: 'Pan hamburguesa, lechuga, tomate, hamburguesa de carne, champiñones, queso cheddar, chorizo parrillero, pepinillos y papas.',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),
  Product(
    name: 'Hamburguesa Súper',
    price: 18.90,
    description: 'Pan hamburguesa, lechuga, tomate, doble hamburguesa de carne, tocino, queso cheddar, pepinillos y papas.',
    category: 'Alimentos',
    subCategory: 'Hamburguesas',
  ),

  // --- SALCHIPAPAS ---
  Product(
    name: 'Salchipapas clásica',
    price: 15.00,
    description: 'Papas, salchicha ahumada.',
    category: 'Alimentos',
    subCategory: 'Salchipapas',
  ),
  Product(
    name: 'Polli papa',
    price: 16.50,
    description: 'Papas y pollo desmenuzado.',
    category: 'Alimentos',
    subCategory: 'Salchipapas',
  ),
  Product(
    name: 'Salchipapas parrillera',
    price: 17.00,
    description: 'Papas, salchicha ahumada y chorizo parrillero.',
    category: 'Alimentos',
    subCategory: 'Salchipapas',
  ),
  Product(
    name: 'Salchi Búfalo',
    price: 19.00,
    description: 'Papas, salchicha Ahumada, cabanossi, chorizo picante.',
    category: 'Alimentos',
    subCategory: 'Salchipapas',
  ),
  Product(
    name: 'Salchi Selvática',
    price: 18.00,
    description: 'Papas, salchicha ahumada, cecina y plátanos fritos.',
    category: 'Alimentos',
    subCategory: 'Salchipapas',
  ),
  Product(
    name: 'Zampa Salchi',
    price: 20.90,
    description: 'Papas, salchicha ahumada, salchicha frankfurter, chorizo parrillero, tocino y doble queso.',
    category: 'Alimentos',
    subCategory: 'Salchipapas',
  ),
  Product(
    name: 'Salchi Alitas',
    price: 18.90,
    description: 'Papas, salchicha ahumada y alitas crocantes.',
    category: 'Alimentos',
    subCategory: 'Salchipapas',
  ),

  // --- ENCHILADAS ---
  Product(
    name: 'Enchilada parrillera',
    price: 17.50,
    description: 'Tortilla de maíz, lechuga, tomate, filete de pollo, queso edam, chorizo parrillero, salsa chimichurri, papas al hilo, salsa guacamole y pico de gallo.',
    category: 'Alimentos',
    subCategory: 'Enchiladas',
  ),
  Product(
    name: 'Enchilada picante',
    price: 18.90,
    description: 'Tortilla de maíz, lechuga, tomate, pollo, chorizo picante en trozos, cabanossi, queso edam, papas al hilo, salsa guacamole y pico de gallo.',
    category: 'Alimentos',
    subCategory: 'Enchiladas',
  ),
  Product(
    name: 'Enchilada con piña o durazno',
    price: 16.50,
    description: 'Tortilla de maíz, lechuga, tomate, filete de pollo, queso edam, piña o durazno en almíbar, papas al hilo, salsa guacamole y pico de gallo.',
    category: 'Alimentos',
    subCategory: 'Enchiladas',
  ),
  Product(
    name: 'Enchilada mixta',
    price: 15.90,
    description: 'Tortilla de maíz, lechuga, tomate, filete de pollo, queso edam, jamón inglés, papas al hilo, salsa guacamole y pico de gallo.',
    category: 'Alimentos',
    subCategory: 'Enchiladas',
  ),
  Product(
    name: 'Enchilada filete de pollo',
    price: 15.90,
    description: 'Tortilla de maiz, lechuga, tomate, filete de pollo, queso edam, papas al hilo, salsa guacamole y pico de gallo.',
    category: 'Alimentos',
    subCategory: 'Enchiladas',
  ),
  Product(
    name: 'Enchilada súper mixta',
    price: 17.50,
    description: 'Tortilla de maíz, lechuga, tomate, filete de pollo, queso edam, jamón inglés, tocino, papas al hilo, salsa guacamole y pico de gallo.',
    category: 'Alimentos',
    subCategory: 'Enchiladas',
  ),
  Product(
    name: 'Zampa Enchilada',
    price: 19.90,
    description: 'Tortilla de maíz, lechuga, tomate, filete de pollo , queso edam, chorizo, tocino, lomito ahumado, champiñones, papas al hilo, salsa guacamole y pico de gallo.',
    category: 'Alimentos',
    subCategory: 'Enchiladas',
  ),

  // --- ESPECIALES Y COMBOS ---
  Product(
    name: 'Promo Zampa',
    price: 10.90,
    description: 'Hamburguesa de pollo + Papas fritas + Gaseosa de 330 ml.',
    category: 'Alimentos',
    subCategory: 'Especiales',
  ),
  Product(
    name: 'Combo Salchi Pollo + Gaseosa',
    price: 12.90,
    description: 'Papas + salchicha ahumada + pollo desmenuzado + gaseosa de 330 ml + cremas.',
    category: 'Alimentos',
    subCategory: 'Especiales',
  ),
  Product(
    name: 'Combo Crunch',
    price: 18.00,
    description: '1/8 de pollo broaster + papas fritas + gaseosa 330ml.',
    category: 'Alimentos',
    subCategory: 'Especiales',
  ),
  Product(
    name: 'Filete de Pollo + Bebida',
    price: 15.90,
    description: 'Filete de pollo + ensalada + papas + vaso de limonada.',
    category: 'Alimentos',
    subCategory: 'Especiales',
  ),
  Product(
    name: 'Combo Salchipapa a lo Pobre',
    price: 15.90,
    description: 'Salchipapa a lo pobre + Vaso de Naranjada.',
    category: 'Alimentos',
    subCategory: 'Especiales',
  ),
  Product(
    name: 'Solitaria De Alitas',
    price: 19.90,
    description: '6 unidades de alitas y papas fritas.',
    category: 'Alimentos',
    subCategory: 'Especiales',
  ),
  Product(
    name: 'Doble Tentación De Alitas',
    price: 30.90,
    description: '12 unidades de alitas y papas fritas.',
    category: 'Alimentos',
    subCategory: 'Especiales',
  ),
  Product(
    name: 'Zampa Triple De Alitas',
    price: 41.90,
    description: '18 unidades de alitas y papas fritas.',
    category: 'Alimentos',
    subCategory: 'Especiales',
  ),
  Product(
    name: 'Nuggets De Pollo',
    price: 17.50,
    description: '6 trozos de pollo empanizados y papas fritas.',
    category: 'Alimentos',
    subCategory: 'Especiales',
  ),
  Product(
    name: 'Pollo Broaster',
    price: 20.90,
    description: '1/4 de pollo, papas fritas y ensalada.',
    category: 'Alimentos',
    subCategory: 'Especiales',
  ),


  // ==========================================
  //               BEBIDAS
  // ==========================================
  
  // --- CAFÉS Y BEBIDAS CALIENTES ---
  Product(
    name: 'Americano 10oz',
    price: 5.00,
    description: '3 oz de café puro y agua.',
    category: 'Bebidas',
    subCategory: 'Cafés y Bebidas Calientes',
  ),
  Product(
    name: 'Latte 10oz',
    price: 8.00,
    description: 'Más leche, poco café.',
    category: 'Bebidas',
    subCategory: 'Cafés y Bebidas Calientes',
  ),
  Product(
    name: 'Capuccino 10oz',
    price: 9.50,
    description: 'Leche batida y café.',
    category: 'Bebidas',
    subCategory: 'Cafés y Bebidas Calientes',
  ),
  Product(
    name: 'Capuccino Con Crema',
    price: 10.50,
    description: 'Leche batida, café y crema.',
    category: 'Bebidas',
    subCategory: 'Cafés y Bebidas Calientes',
  ),
  Product(
    name: 'Submarino',
    price: 7.00,
    description: 'Leche batida y barra de chocolate.',
    category: 'Bebidas',
    subCategory: 'Cafés y Bebidas Calientes',
  ),
  Product(
    name: 'Zampa Capuccino',
    price: 12.90,
    description: 'Leche batida, café, jarabe de toffee de nueces, crema, trocitos de nueces y granos de chocolate.',
    category: 'Bebidas',
    subCategory: 'Cafés y Bebidas Calientes',
  ),

  // --- BEBIDAS FRÍAS ---
  Product(
    name: 'Frappe 16oz',
    price: 13.50,
    description: '',
    category: 'Bebidas',
    subCategory: 'Bebidas Frías',
  ),
  Product(
    name: 'Naranjada 16oz',
    price: 7.00,
    description: '',
    category: 'Bebidas',
    subCategory: 'Bebidas Frías',
  ),
  Product(
    name: 'Limonada Frutos Rojos',
    price: 8.00,
    description: '',
    category: 'Bebidas',
    subCategory: 'Bebidas Frías',
  ),
  Product(
    name: 'Limonada Hierba Buena',
    price: 8.00,
    description: '',
    category: 'Bebidas',
    subCategory: 'Bebidas Frías',
  ),
  Product(
    name: 'Frozen De Frutos Rojos',
    price: 11.50,
    description: 'Jugo Frozen De Frutos Rojos',
    category: 'Bebidas',
    subCategory: 'Bebidas Frías',
  ),
  Product(
    name: 'Frozen De Maracuyá',
    price: 11.50,
    description: 'Jugo Frozen De Maracuyá',
    category: 'Bebidas',
    subCategory: 'Bebidas Frías',
  ),
  Product(
    name: 'Gaseosas 500ml',
    price: 4.00,
    description: 'Bebida gasificada.',
    category: 'Bebidas',
    subCategory: 'Bebidas Frías',
  ),
  Product(
    name: 'Agua Mineral',
    price: 3.50,
    description: 'Agua mineral Personal.',
    category: 'Bebidas',
    subCategory: 'Bebidas Frías',
  ),

  // --- JUGOS ---
  Product(
    name: 'Jugo de Papaya 16oz',
    price: 8.00,
    description: '',
    category: 'Bebidas',
    subCategory: 'Jugos',
  ),
  Product(
    name: 'Mix de frutas a elección 16oz',
    price: 12.90,
    description: 'Máx 3 frutas',
    category: 'Bebidas',
    subCategory: 'Jugos',
  ),
  Product(
    name: 'Jugo de Fresa 16oz',
    price: 10.00,
    description: '',
    category: 'Bebidas',
    subCategory: 'Jugos',
  ),
  Product(
    name: 'Jugo de Durazno 16oz',
    price: 9.00,
    description: '',
    category: 'Bebidas',
    subCategory: 'Jugos',
  ),
  Product(
    name: 'Jugo de Naranja 16oz',
    price: 7.00,
    description: 'Jugo de naranja',
    category: 'Bebidas',
    subCategory: 'Jugos',
  ),
  Product(
    name: 'Jugo de Mango 16oz',
    price: 10.00,
    description: 'Jugo de pura pulpa de mango',
    category: 'Bebidas',
    subCategory: 'Jugos',
  ),
];