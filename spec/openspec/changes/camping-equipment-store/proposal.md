# Proposal: Camping Equipment Store

> **Change slug:** `camping-equipment-store`
> **Priority:** P1
> **Affected domains:** `idea-capture`, `sdlc-process`, `operations`, `testing-standards`
> **Submitter:** @ralphke
> **Created:** 2026-05-28
> **Status:** Draft

---

## Intent

Outdoor shoppers and small camping retailers need a modern way to browse and order camping equipment from a scalable, containerized platform. Existing workshop artifacts do not yet include an end-to-end ecommerce reference application with SQL Server 2025 test data, product images, and a C# implementation.

This change will deliver a reusable camping gear storefront built in C# with a scalable containerized deployment model, backed by a SQL Server 2025 database. It will include seeded product, category, inventory, and image test data so the application can be validated in a realistic scenario.

## Scope

- Create a C# ecommerce application for selling camping equipment.
- Build a scalable containerized platform using Docker and container orchestration patterns appropriate for the workshop.
- Target SQL Server 2025 as the primary database, including schema, migrations, and seeded test data.
- Provide sample product image fixtures and metadata for test/demo scenarios.
- Include a seed-data workflow for test products, categories, inventory, and images.
- Expose at least one customer-facing storefront flow and one admin-style data seeding flow.

## Out of Scope

- Production payment gateway integration or real credit card processing.
- Cloud provider provisioning, managed Kubernetes cluster setup, or production infrastructure automation.
- Multi-tenant ecommerce support.
- Real user authentication beyond lightweight demo access patterns.
- Full production-grade observability and compliance controls.

## Approach

Use ASP.NET Core to implement a lightweight ecommerce backend and storefront for camping equipment, with containerization for local deployment and operational scalability. SQL Server 2025 will host product, category, inventory, image metadata, and order data.

The solution will include Docker configuration, a database initialization/seeding path, and test fixture content for camping equipment images and product data. The architecture should be extensible for later SRE and operations work, while keeping the first iteration focused on functional ecommerce flows and database-backed test data.

## Scenarios

### Scenario: Browse camping equipment
- GIVEN the containerized ecommerce application is running
- WHEN a customer navigates to the storefront and selects camping gear categories
- THEN the customer sees a list of camping equipment products with names, prices, availability, and image thumbnails
- AND the product details page shows a sample image, description, and inventory status

### Scenario: Place an order with available inventory
- GIVEN seeded inventory exists for a camping tent product
- WHEN a customer adds the product to cart and completes checkout
- THEN the order is accepted
- AND the order record is persisted in SQL Server 2025 with product, quantity, and customer details

### Scenario: Fail checkout when insufficient inventory
- GIVEN a product has zero available stock
- WHEN a customer attempts to purchase that product
- THEN the checkout flow returns a clear validation error
- AND the order is not created in the database

### Scenario: Seed test data into SQL Server 2025
- GIVEN the application is deployed in containers
- WHEN the seed workflow runs
- THEN test product, category, inventory, and image metadata are created in SQL Server 2025
- AND sample image fixtures are available for storefront rendering

## Acceptance Criteria

- [ ] A C# ecommerce application is implemented and runnable in containers.
- [ ] The platform uses SQL Server 2025 with schema, migrations, and seeded test data.
- [ ] Product image test fixtures are included and usable in the storefront.
- [ ] The checkout flow handles both successful purchase and inventory failure cases.
- [ ] The proposal documents affected domains and delivery scope clearly.

## Affected Domains

- `idea-capture`
- `sdlc-process`
- `operations`
- `testing-standards`
