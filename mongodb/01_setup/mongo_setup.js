// ============================================================
// FILE: mongodb/01_setup/mongo_setup.js
// PROJECT: SQL & NoSQL Mobile Catalog Analysis — NMIMS Mumbai
// ============================================================

use("mobile_catalog");

db.smartphones.drop();
db.brands.drop();
db.price_summary.drop();

db.createCollection("smartphones", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["brand", "model", "price", "specs"],
      properties: {
        brand:  { bsonType: "string" },
        model:  { bsonType: "string" },
        price:  { bsonType: ["double","null"] },
        rating: { bsonType: ["double","null"] },
        specs:  { bsonType: "object" }
      }
    }
  },
  validationAction: "warn"
});

db.createCollection("brands");
db.createCollection("price_summary");

db.smartphones.createIndex({ brand: 1 }, { name: "idx_brand" });
db.smartphones.createIndex({ price: 1 }, { name: "idx_price" });
db.smartphones.createIndex({ rating: -1 }, { name: "idx_rating_desc" });
db.smartphones.createIndex({ "specs.connectivity.has_5g": 1 }, { name: "idx_5g" });
db.smartphones.createIndex({ brand: 1, price: 1 }, { name: "idx_brand_price" });
db.smartphones.createIndex({ model: "text", brand: "text" }, { name: "idx_text_search" });

print("MongoDB setup completed successfully.");
