// ============================================================
// FILE: mongodb/02_pipelines/aggregation_pipelines.js
// PROJECT: SQL & NoSQL Mobile Catalog Analysis — NMIMS Mumbai
// DESC: 22 MongoDB aggregation pipelines mirroring SQL queries
// ============================================================

use("mobile_catalog");

// Ensure text index exists
db.smartphones.createIndex({ model: "text", brand: "text" });

// MQ-01: 5G phones under 30K with NFC
db.smartphones.find({
  "specs.connectivity.has_5g": true, "specs.connectivity.has_nfc": true, price: { $lt: 30000 }
}, { brand: 1, model: 1, price: 1 }).sort({ price: 1 });

// MQ-02: Top 10 highest-rated phones
db.smartphones.find({ rating: { $ne: null } }, { brand: 1, model: 1, rating: 1, price: 1 })
  .sort({ rating: -1, price: 1 }).limit(10);

// MQ-03: IR Blaster + fast charging > 65W
db.smartphones.aggregate([
  { $match: { "specs.connectivity.has_ir_blaster": true, "specs.battery.fast_charging_w": { $gt: 65 } } },
  { $project: { brand: 1, model: 1, fast_charging_w: "$specs.battery.fast_charging_w", price: 1 } },
  { $sort: { fast_charging_w: -1 } }
]);

// MQ-04: Brands with NO 5G models
db.smartphones.aggregate([
  { $group: { _id: "$brand", has_any_5g: { $max: "$specs.connectivity.has_5g" }, total: { $sum: 1 } } },
  { $match: { has_any_5g: false } },
  { $project: { brand: "$_id", total: 1, _id: 0 } },
  { $sort: { brand: 1 } }
]);

// MQ-05: Avg price per brand (5+ models)
db.smartphones.aggregate([
  { $match: { price: { $ne: null } } },
  { $group: { _id: "$brand", total_models: { $sum: 1 }, avg_price: { $avg: "$price" }, min_price: { $min: "$price" }, max_price: { $max: "$price" } } },
  { $match: { total_models: { $gte: 5 } } },
  { $project: { brand: "$_id", total_models: 1, avg_price: { $round: ["$avg_price", 2] }, min_price: 1, max_price: 1, _id: 0 } },
  { $sort: { avg_price: -1 } }
]);

// MQ-06: 5G adoption rate per brand
db.smartphones.aggregate([
  { $group: { _id: "$brand", total: { $sum: 1 }, five_g_count: { $sum: { $cond: ["$specs.connectivity.has_5g", 1, 0] } } } },
  { $match: { total: { $gte: 3 } } },
  { $project: { brand: "$_id", total: 1, five_g_count: 1, pct_5g: { $round: [{ $multiply: [{ $divide: ["$five_g_count","$total"] }, 100] }, 1] }, _id: 0 } },
  { $sort: { pct_5g: -1 } }
]);

// MQ-07: $bucket — price-tier segmentation
db.smartphones.aggregate([
  { $match: { price: { $ne: null } } },
  { $bucket: {
      groupBy: "$price",
      boundaries: [0, 10000, 30000, 60000, 500000],
      default: "Unknown",
      output: { count: { $sum: 1 } }
  } }
]);

// MQ-08: Price tier pivot per brand
db.smartphones.aggregate([
  { $match: { price: { $ne: null } } },
  { $group: {
      _id: "$brand",
      budget:        { $sum: { $cond: [{ $lt: ["$price", 10000] }, 1, 0] } },
      mid_range:     { $sum: { $cond: [{ $and: [{ $gte: ["$price", 10000] }, { $lt: ["$price", 30000] }] }, 1, 0] } },
      flagship:      { $sum: { $cond: [{ $and: [{ $gte: ["$price", 30000] }, { $lt: ["$price", 60000] }] }, 1, 0] } },
      ultra_premium: { $sum: { $cond: [{ $gte: ["$price", 60000] }, 1, 0] } }
  } },
  { $project: { brand: "$_id", budget: 1, mid_range: 1, flagship: 1, ultra_premium: 1, _id: 0 } },
  { $sort: { brand: 1 } }
]);

// MQ-09: Processor brand market share
var total = db.smartphones.countDocuments();
db.smartphones.aggregate([
  { $group: { _id: "$specs.processor.brand", count: { $sum: 1 } } },
  { $project: { processor_brand: "$_id", model_count: "$count", market_share_pct: { $round: [{ $multiply: [{ $divide: ["$count", total] }, 100] }, 1] }, _id: 0 } },
  { $sort: { model_count: -1 } }
]);

// MQ-10: Multi-dimension $facet summary
db.smartphones.aggregate([
  { $facet: {
      by_brand: [{ $group: { _id: "$brand", count: { $sum: 1 } } }, { $sort: { count: -1 } }, { $limit: 5 }],
      by_os: [{ $group: { _id: "$specs.os", count: { $sum: 1 } } }, { $sort: { count: -1 } }],
      price_stats: [{ $group: { _id: null, avg: { $avg: "$price" }, min: { $min: "$price" }, max: { $max: "$price" }, total: { $sum: 1 } } }]
  } }
]);

// MQ-11: Snapdragon 120Hz+ phones
db.smartphones.aggregate([
  { $match: { "specs.processor.brand": { $regex: /snapdragon/i }, "specs.display.refresh_rate_hz": { $gte: 120 } } },
  { $project: { brand: 1, model: 1, price: 1, processor: "$specs.processor.brand", refresh_hz: "$specs.display.refresh_rate_hz" } },
  { $sort: { refresh_hz: -1, price: 1 } }
]);

// MQ-12: Brand connectivity summary
db.smartphones.aggregate([
  { $group: {
      _id: "$brand", total: { $sum: 1 },
      five_g: { $sum: { $cond: ["$specs.connectivity.has_5g", 1, 0] } },
      nfc: { $sum: { $cond: ["$specs.connectivity.has_nfc", 1, 0] } },
      ir: { $sum: { $cond: ["$specs.connectivity.has_ir_blaster", 1, 0] } }
  } },
  { $project: { brand: "$_id", total: 1, five_g: 1, nfc: 1, ir: 1, _id: 0 } },
  { $sort: { total: -1 } }
]);

// MQ-13: Top 3 most expensive phones per brand
db.smartphones.aggregate([
  { $match: { price: { $ne: null } } },
  { $setWindowFields: { partitionBy: "$brand", sortBy: { price: -1 }, output: { price_rank: { $denseRank: {} } } } },
  { $match: { price_rank: { $lte: 3 } } },
  { $project: { brand: 1, model: 1, price: 1, price_rank: 1, _id: 0 } },
  { $sort: { brand: 1, price_rank: 1 } }
]);

// MQ-14: Running total of models by brand avg price
db.smartphones.aggregate([
  { $group: { _id: "$brand", model_count: { $sum: 1 }, avg_price: { $avg: "$price" } } },
  { $sort: { avg_price: -1 } },
  { $setWindowFields: { sortBy: { avg_price: -1 }, output: { running_total: { $sum: "$model_count", window: { documents: ["unbounded","current"] } } } } },
  { $project: { brand: "$_id", model_count: 1, avg_price: { $round: ["$avg_price", 2] }, running_total: 1, _id: 0 } }
]);

// MQ-15: LAG — price vs. previous brand
db.smartphones.aggregate([
  { $match: { price: { $ne: null } } },
  { $group: { _id: "$brand", avg_price: { $avg: "$price" } } },
  { $sort: { avg_price: -1 } },
  { $setWindowFields: { sortBy: { avg_price: -1 }, output: { prev_brand_avg: { $shift: { output: "$avg_price", by: 1 } } } } },
  { $project: { brand: "$_id", avg_price: { $round: ["$avg_price", 2] }, prev_brand_avg: { $round: ["$prev_brand_avg", 2] }, price_diff: { $round: [{ $subtract: ["$avg_price","$prev_brand_avg"] }, 2] }, _id: 0 } }
]);

// MQ-16: DENSE_RANK brands by avg rating
db.smartphones.aggregate([
  { $match: { rating: { $ne: null } } },
  { $group: { _id: "$brand", avg_rating: { $avg: "$rating" } } },
  { $sort: { avg_rating: -1 } },
  { $setWindowFields: { sortBy: { avg_rating: -1 }, output: { rating_rank: { $denseRank: {} } } } },
  { $project: { brand: "$_id", avg_rating: { $round: ["$avg_rating", 2] }, rating_rank: 1, _id: 0 } }
]);

// MQ-17: Phones above brand average price
db.smartphones.aggregate([
  { $match: { price: { $ne: null } } },
  { $lookup: {
      from: "smartphones",
      let: { brand: "$brand" },
      pipeline: [
        { $match: { $expr: { $eq: ["$brand","$$brand"] }, price: { $ne: null } } },
        { $group: { _id: null, brand_avg: { $avg: "$price" } } }
      ],
      as: "brand_stats"
  } },
  { $unwind: "$brand_stats" },
  { $match: { $expr: { $gt: ["$price","$brand_stats.brand_avg"] } } },
  { $project: { brand: 1, model: 1, price: 1, brand_avg: { $round: ["$brand_stats.brand_avg", 2] }, price_above_avg: { $round: [{ $subtract: ["$price","$brand_stats.brand_avg"] }, 2] }, _id: 0 } },
  { $sort: { price_above_avg: -1 } },
  { $limit: 20 }
]);

// MQ-18: Brands where ALL models are 5G
db.smartphones.aggregate([
  { $group: { _id: "$brand", total: { $sum: 1 }, non_5g_count: { $sum: { $cond: [{ $eq: ["$specs.connectivity.has_5g", false] }, 1, 0] } } } },
  { $match: { non_5g_count: 0, total: { $gte: 1 } } },
  { $project: { brand: "$_id", total_models: "$total", _id: 0 } },
  { $sort: { brand: 1 } }
]);

// MQ-19: Most common refresh rate per brand
db.smartphones.aggregate([
  { $match: { "specs.display.refresh_rate_hz": { $ne: null } } },
  { $group: { _id: { brand: "$brand", hz: "$specs.display.refresh_rate_hz" }, count: { $sum: 1 } } },
  { $sort: { "_id.brand": 1, count: -1 } },
  { $group: { _id: "$_id.brand", most_common_hz: { $first: "$_id.hz" }, freq: { $first: "$count" } } },
  { $project: { brand: "$_id", most_common_hz: 1, freq: 1, _id: 0 } },
  { $sort: { brand: 1 } }
]);

// MQ-20: Text search for 'OnePlus'
db.smartphones.find({ $text: { $search: "OnePlus" } }, { brand: 1, model: 1, price: 1 }).limit(10);

// MQ-21: $merge brand summary into price_summary
db.smartphones.aggregate([
  { $match: { price: { $ne: null } } },
  { $group: { _id: "$brand", avg_price: { $avg: "$price" }, min_price: { $min: "$price" }, max_price: { $max: "$price" }, model_count: { $sum: 1 }, avg_rating: { $avg: "$rating" } } },
  { $project: { _id: "$_id", brand: "$_id", avg_price: { $round: ["$avg_price", 2] }, min_price: 1, max_price: 1, model_count: 1, avg_rating: { $round: ["$avg_rating", 2] } } },
  { $merge: { into: "price_summary", whenMatched: "replace", whenNotMatched: "insert" } }
]);

// MQ-22: 3-brand rolling average price
db.smartphones.aggregate([
  { $match: { price: { $ne: null } } },
  { $group: { _id: "$brand", avg_price: { $avg: "$price" } } },
  { $sort: { avg_price: -1 } },
  { $setWindowFields: { sortBy: { avg_price: -1 }, output: { rolling_3_avg: { $avg: "$avg_price", window: { documents: [-1, 1] } } } } },
  { $project: { brand: "$_id", avg_price: { $round: ["$avg_price", 2] }, rolling_3_avg: { $round: ["$rolling_3_avg", 2] }, _id: 0 } }
]);
