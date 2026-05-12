const admin = require('firebase-admin');
const fs = require('fs');
const path = require('path');

// 1. Initialize Firebase Admin with the service account
const serviceAccount = require('./guerniss.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// 2. Load the JSON data
const rawData = fs.readFileSync('products.json', 'utf8');
const data = JSON.parse(rawData);

async function importData() {
  const products = data.products;
  const collectionRef = db.collection('products');
  
  console.log(`Starting import of ${products.length} products...`);
  
  // Using batches for efficiency (Firestore limit is 500 per batch)
  let batch = db.batch();
  let count = 0;

  for (const product of products) {
    // Map Shopify fields to your App's ProductModel fields if necessary
    // Here we use the Shopify ID as the document ID
    const docRef = collectionRef.doc(product.id.toString());
    
    // Simple mapping - adjusting types to match your ProductModel
    const productData = {
      sellerId: 'admin_seed', // Default seller ID for seeded products
      sellerName: product.vendor || 'Guerniss',
      name: product.title,
      description: product.body_html.replace(/<[^>]*>?/gm, ''), // Strip HTML
      price: parseFloat(product.variants[0].price),
      category: product.product_type || 'General',
      imageUrls: product.images.map(img => img.src),
      stock: 100, // Default stock
      createdAt: admin.firestore.Timestamp.fromDate(new Date(product.created_at)),
      isActive: true
    };

    batch.set(docRef, productData);
    count++;

    if (count % 400 === 0) {
      await batch.commit();
      batch = db.batch();
      console.log(`Imported ${count} items...`);
    }
  }

  await batch.commit();
  console.log(`Successfully imported ${count} products to Firestore!`);
}

importData().catch(err => {
  console.error('Error importing data:', err);
  process.exit(1);
});
