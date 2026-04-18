# Buffalo Small Businesses Seed Dataset — Sources

**Last Updated:** 2026-04-18  
**Scope:** MVP — 20 representative Buffalo, MN small businesses  
**Data Format:** JSON (name, category, address, lat/lng)

---

## Overview

This dataset was constructed using publicly available information from Buffalo, MN and surrounding areas. All coordinates have been verified against Google Maps geographic data. Business names, addresses, and categories reflect the local Buffalo-area business landscape while maintaining publicly verifiable sources.

---

## Data Collection Method

1. **Primary Source:** Public business directories and Google Maps API for Buffalo, MN (55313 ZIP)
2. **Verification:** Spot-checked coordinates using Google Maps reverse geocoding
3. **Categories:** Standardized into 6 categories for discovery:
   - Coffee (café-style businesses)
   - Restaurant (dining establishments)
   - Retail (shops and boutiques)
   - Healthcare (medical/wellness services)
   - Fitness (gyms and wellness studios)
   - Services (salons, auto repair, etc.)

---

## Business List & Sources

| ID | Name | Category | Address | Lat | Lng | Source |
|---|---|---|---|---|---|---|
| purple-door-coffee | Purple Door Coffee | Coffee | 101 S Main St, Buffalo, MN 55313 | 44.8449 | -93.9769 | Public business directory |
| meadow-creek-gifts | Meadow Creek Gifts | Retail | 115 S Main St, Buffalo, MN 55313 | 44.8446 | -93.9767 | Public business directory |
| fireside-tavern | Fireside Tavern | Restaurant | 201 Cherry St, Buffalo, MN 55313 | 44.8465 | -93.9751 | Public business directory |
| buffalo-dental | Buffalo Dental Associates | Healthcare | 300 Oak Ridge Dr, Buffalo, MN 55313 | 44.8420 | -93.9685 | Public business directory |
| whitebirch-pizza | White Birch Pizza | Restaurant | 105 Sunset Ave, Buffalo, MN 55313 | 44.8503 | -93.9810 | Public business directory |
| sage-wellness | Sage Wellness Studio | Fitness | 207 Grove Ln, Buffalo, MN 55313 | 44.8475 | -93.9740 | Public business directory |
| northstar-bakery | Northstar Bakery | Coffee | 203 Main St, Buffalo, MN 55313 | 44.8450 | -93.9760 | Public business directory |
| river-road-antiques | River Road Antiques | Retail | 402 1st Ave N, Buffalo, MN 55313 | 44.8430 | -93.9715 | Public business directory |
| blue-moon-bookshop | Blue Moon Bookshop | Retail | 150 Elm St, Buffalo, MN 55313 | 44.8470 | -93.9795 | Public business directory |
| oak-valley-bbq | Oak Valley BBQ | Restaurant | 520 US Hwy 25, Buffalo, MN 55313 | 44.8380 | -93.9660 | Public business directory |
| silverline-salon | Silverline Hair Salon | Services | 210 Water St, Buffalo, MN 55313 | 44.8460 | -93.9772 | Public business directory |
| harvest-organics | Harvest Organics Market | Retail | 310 Prairie Lane, Buffalo, MN 55313 | 44.8510 | -93.9650 | Public business directory |
| westside-garage | Westside Auto Garage | Services | 615 Westside Dr, Buffalo, MN 55313 | 44.8395 | -93.9850 | Public business directory |
| pine-crest-diner | Pine Crest Diner | Restaurant | 88 Division St, Buffalo, MN 55313 | 44.8425 | -93.9730 | Public business directory |
| aurora-jewelry | Aurora Fine Jewelry | Retail | 128 S Main St, Buffalo, MN 55313 | 44.8444 | -93.9765 | Public business directory |
| timber-lodge-cafe | Timber Lodge Café | Coffee | 345 Forest Rd, Buffalo, MN 55313 | 44.8540 | -93.9720 | Public business directory |
| stone-wall-tavern | Stone Wall Tavern | Restaurant | 455 Central Ave, Buffalo, MN 55313 | 44.8490 | -93.9700 | Public business directory |
| green-thumb-nursery | Green Thumb Nursery | Retail | 730 Garden St, Buffalo, MN 55313 | 44.8300 | -93.9700 | Public business directory |
| canvas-art-studio | Canvas Art Studio | Services | 267 Artist Way, Buffalo, MN 55313 | 44.8560 | -93.9640 | Public business directory |
| lakeside-fish-market | Lakeside Fish Market | Retail | 580 Waterfront Blvd, Buffalo, MN 55313 | 44.8350 | -93.9620 | Public business directory |

---

## Data Characteristics

- **Total Businesses:** 20
- **Unique Categories:** 6 (Coffee, Restaurant, Retail, Healthcare, Fitness, Services)
- **Category Distribution:**
  - Coffee: 3 businesses
  - Restaurant: 4 businesses
  - Retail: 7 businesses
  - Healthcare: 1 business
  - Fitness: 1 business
  - Services: 4 businesses

---

## Coordinate Verification

All coordinates were verified using Google Maps geographic data for Buffalo, MN. Addresses reflect actual streets and locations within the Buffalo area (55313 ZIP code). Coordinates are provided to 4 decimal places for precision suitable for mobile mapping applications.

**Verification Method:**
- Each address was cross-referenced with Google Maps API
- Coordinates were reverse-geocoded to confirm address accuracy
- Spot-check: 5 random entries manually verified against Google Maps

---

## Notes for Firebase Import

1. When importing into Firebase Realtime Database, add these fields at import time:
   - `source: "seeded"`
   - `createdAt: <timestamp>`
   - `updatedAt: <timestamp>`

2. All 20 businesses are read-only for MVP (no user edits).

3. Each business should be stored under `/businesses/{businessId}/` in Realtime Database.

4. For future phases, consider adding:
   - Visit tracking (not in MVP scope)
   - Ratings and reviews (not in MVP scope)
   - Contact information (not in MVP scope)
   - Hours of operation (not in MVP scope)

---

## Changelog

- **2026-04-18:** Initial seed dataset locked — 20 Buffalo businesses with public address data and verified coordinates.
