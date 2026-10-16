const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const assert = require("node:assert/strict");
const root = path.resolve(__dirname, "..");
const read = name => JSON.parse(fs.readFileSync(path.join(root, "data", name), "utf8"));
const html = fs.readFileSync(path.join(root, "pet-value-calculator.html"), "utf8");
const start = html.indexOf("function overridePetToCatalogPet(");
const end = html.indexOf("function renderSlots(", start);
assert(start >= 0 && end > start, "Calculator catalog functions must be present");
const context = {
  normalizeRarity: value => value,
  slugImage: slug => "/assets/pets/" + slug + ".png"
};
vm.runInNewContext(html.slice(start, end), context);
const benchmark = read("adopt-me-values.json");
benchmark.petIndex = Object.fromEntries(benchmark.pets.map(pet => [pet.slug, pet]));
const legacy = read("adopt-me-calculator-values.json");
const overrides = read("adopt-me-calculator-overrides.json");
const launch = read("adopt-me-new-pet-overrides.json");
const pages = read("adopt-me-pet-pages.json");
const catalog = read("adopt-me-pet-catalog.json");
const merged = context.mergeCatalog(benchmark, legacy, overrides, launch, pages);
const bySlug = new Map(merged.map(pet => [pet.slug, pet]));
assert.equal(merged.length, bySlug.size, "No duplicate picker pets");
for (const pet of overrides.pets) {
  assert(bySlug.has(pet.slug), "Published override must reach picker: " + pet.slug);
  const selected = bySlug.get(pet.slug);
  assert.deepEqual(selected.matrix, pet.values, "Picker must use audited matrix: " + pet.slug);
  const page = pages.pets.find(row => row.slug === pet.slug);
  assert(page, "Published override must have pet-page data: " + pet.slug);
  assert.equal(page.values.default, pet.values.default.flyRide, "Page FR lane must match calculator: " + pet.slug);
}
// A stale launch projection cannot shadow a refreshed tracker matrix.
const example = overrides.pets.find(pet => !benchmark.petIndex[pet.slug]);
const staleLaunch = { pets: [{ ...example, values: { default: { noPotion: 999999 } } }] };
const staleMerged = context.mergeCatalog(benchmark, legacy, overrides, staleLaunch, pages);
assert.deepEqual(staleMerged.find(pet => pet.slug === example.slug).matrix, example.values);
for (const slug of ["stitches", "copycat", "shoebill", "boohoo"]) {
  const selected = bySlug.get(slug);
  assert.equal(selected.source, "official-pending", slug + " remains unpriced");
  assert.equal(selected.values, null);
  const entry = catalog.entries.find(row => row.slug === slug);
  const page = pages.pets.find(row => row.slug === slug);
  assert.equal(entry.image, page.image);
  assert.equal(selected.image, entry.image);
  assert(fs.existsSync(path.join(root, entry.image.slice(1))));
  const pageHtml = fs.readFileSync(path.join(root, page.pageUrl.slice(1)), "utf8");
  assert(pageHtml.includes(entry.image), "Pet HTML and JSON artwork must agree");
}
assert.equal(overrides.remainingUnmatchedCount, 0);
assert.equal(overrides.pets.length, overrides.trackerMatchedCount + overrides.manualResolvedCount);
console.log("Calculator catalog tests passed: all published overrides selectable, page values aligned, stale projections rejected, new pets pending.");
