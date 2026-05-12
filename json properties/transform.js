const fs = require('fs');

const data = JSON.parse(fs.readFileSync('products.json', 'utf8'));

const transformed = {
  __collections__: {
    products: {}
  }
};

data.products.forEach(product => {
  const docId = product.id.toString();
  transformed.__collections__.products[docId] = product;
});

fs.writeFileSync('products_formatted.json', JSON.stringify(transformed, null, 2));
console.log('Transformation complete: products_formatted.json created.');
