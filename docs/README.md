# QuebradoBank Documentation

Welcome to the QuebradoBank documentation! This comprehensive guide is designed for internal contributors and developers working on the QuebradoBank API project.

## Table of Contents

### 📋 Overview Documentation
- [🏗️ Architecture Overview](architecture.md) - System architecture, infrastructure, and component interactions
- [🔌 External Integrations](integrations.md) - APIs, services, and external system integrations  
- [💼 Core Business Logic](business-logic.md) - Business processes, rules, and workflows
- [⭐ Features Overview](features.md) - Complete list of application features

### 🔧 Feature Documentation
- [👤 User Management](features/user-management.md) - User registration, authentication, and profile management
- [🏦 Account Management](features/account-management.md) - Bank account creation and management  
- [💰 Financial Operations](features/financial-operations.md) - Deposits, withdrawals, and transfers
- [🔐 Authentication & Authorization](features/authentication.md) - JWT tokens, auth middleware, and security
- [📍 Address Validation](features/address-validation.md) - ViaCep integration for Brazilian postal codes

## Quick Start

QuebradoBank is a Phoenix-based Elixir API that provides banking functionality with user management, account operations, and financial transactions. The system is containerized with Docker and deployed to AWS EC2 with automated CI/CD pipelines.

### Key Technologies
- **Backend**: Elixir/Phoenix
- **Database**: PostgreSQL  
- **Deployment**: Docker + AWS EC2
- **Authentication**: JWT tokens
- **CI/CD**: GitHub Actions

### Core Concepts
1. **Users** - Individual customers with accounts
2. **Accounts** - Bank accounts linked 1:1 with users
3. **Transactions** - Financial operations (deposits, withdrawals, transfers)
4. **Authentication** - JWT-based API security
5. **External Validation** - Brazilian address verification via ViaCep

## Getting Started for Contributors

1. **Read the Architecture Overview** to understand the system design
2. **Review Business Logic** to understand core processes  
3. **Explore Feature Documentation** for specific functionality
4. **Check External Integrations** for API dependencies

## Documentation Maintenance

This documentation is organized into modular files for easy maintenance:
- Each feature has its own dedicated file in `docs/features/`
- Architecture and integration docs are separate from feature docs
- Cross-references link related concepts across documents
- Each document is self-contained but interconnected

For updates, modify the relevant feature document and update cross-references as needed.