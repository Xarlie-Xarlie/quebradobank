# Features Overview

This document provides a comprehensive list of all QuebradoBank features, their purposes, and how they fit into the overall business logic.

## Feature Categories

QuebradoBank features are organized into five main categories:

1. **User Management** - User lifecycle and profile management
2. **Account Management** - Bank account operations and management
3. **Financial Operations** - Core banking transactions and money movements
4. **Authentication & Authorization** - Security and access control
5. **Address Validation** - External address verification services

## Core Features List

### 1. User Management Features

#### User Registration
- **Purpose**: Allow new customers to create accounts in the system
- **Business Value**: Customer acquisition and onboarding
- **Key Workflows**: Data collection, validation, account creation
- **Dependencies**: Address Validation, Account Management
- **API Endpoint**: `POST /api/users`

#### User Authentication (Login)
- **Purpose**: Secure user access to protected resources
- **Business Value**: Security and personalized service access
- **Key Workflows**: Credential verification, token generation
- **Dependencies**: Authentication system
- **API Endpoint**: `POST /api/users/login`

#### User Profile Management
- **Purpose**: Allow users to update their personal information
- **Business Value**: Data accuracy and customer satisfaction
- **Key Workflows**: Profile updates, validation, persistence
- **Dependencies**: Address Validation (for CEP updates)
- **API Endpoints**: `PUT /api/users/:id`, `GET /api/users/:id`

#### User Account Deletion
- **Purpose**: Allow users to close their accounts
- **Business Value**: Compliance with data privacy regulations
- **Key Workflows**: Account closure, data cleanup
- **Dependencies**: Account Management (balance verification)
- **API Endpoint**: `DELETE /api/users/:id`

### 2. Account Management Features

#### Account Creation
- **Purpose**: Automatically create bank accounts for new users
- **Business Value**: Seamless onboarding with immediate banking access
- **Key Workflows**: Zero-balance account creation, user linking
- **Dependencies**: User Management
- **API Endpoint**: `POST /api/accounts`

#### Account Information Retrieval
- **Purpose**: Provide users with their account details and balance
- **Business Value**: Transparency and account management
- **Key Workflows**: Account lookup, balance display
- **Dependencies**: Authentication
- **Integration**: Embedded in user profile endpoints

### 3. Financial Operations Features

#### Account Deposits
- **Purpose**: Allow users to add money to their accounts
- **Business Value**: Account funding and balance increases
- **Key Workflows**: Amount validation, balance update, confirmation
- **Dependencies**: Account Management, Authentication
- **API Endpoint**: `POST /api/accounts/deposit`

#### Account Withdrawals  
- **Purpose**: Allow users to withdraw money from their accounts
- **Business Value**: Access to funds and balance management
- **Key Workflows**: Sufficient funds check, balance deduction, confirmation
- **Dependencies**: Account Management, Authentication
- **API Endpoint**: `POST /api/accounts/withdraw`

#### Account-to-Account Transfers
- **Purpose**: Enable money transfers between different user accounts
- **Business Value**: Inter-customer payments and money movement
- **Key Workflows**: Multi-account validation, atomic transaction, confirmation
- **Dependencies**: Account Management, Authentication
- **API Endpoint**: `POST /api/accounts/transaction`

### 4. Authentication & Authorization Features

#### JWT Token Generation
- **Purpose**: Provide secure authentication tokens for API access
- **Business Value**: Stateless authentication and scalability
- **Key Workflows**: Token creation, signing, expiration setting
- **Dependencies**: User Management
- **Integration**: Part of login workflow

#### Authentication Middleware
- **Purpose**: Protect sensitive endpoints from unauthorized access
- **Business Value**: Security and access control
- **Key Workflows**: Token validation, user identification, access granting
- **Dependencies**: JWT Token system
- **Integration**: Applied to all protected endpoints

#### Authorization Control
- **Purpose**: Ensure users can only access their own resources
- **Business Value**: Data privacy and security compliance
- **Key Workflows**: User identity verification, resource ownership checking
- **Dependencies**: Authentication system
- **Integration**: Built into all user-specific operations

### 5. Address Validation Features

#### Brazilian Postal Code (CEP) Validation
- **Purpose**: Verify and standardize user addresses during registration
- **Business Value**: Data quality and address verification
- **Key Workflows**: CEP lookup, address retrieval, validation confirmation
- **Dependencies**: ViaCep API integration
- **Integration**: Part of user registration and update workflows

## Feature Relationship Matrix

```
┌─────────────────────┬─────────┬─────────┬─────────┬─────────┬─────────┐
│                     │  User   │ Account │Financial│  Auth   │ Address │
│       Feature       │  Mgmt   │  Mgmt   │   Ops   │ & Auth  │  Valid  │
├─────────────────────┼─────────┼─────────┼─────────┼─────────┼─────────┤
│ User Registration   │    ●    │    ◐    │         │         │    ◐    │
│ User Login          │    ●    │         │         │    ◐    │         │
│ Profile Updates     │    ●    │         │         │    ●    │    ◐    │
│ Account Creation    │    ◐    │    ●    │         │    ●    │         │
│ Deposits            │         │    ●    │    ●    │    ●    │         │
│ Withdrawals         │         │    ●    │    ●    │    ●    │         │
│ Transfers           │         │    ●    │    ●    │    ●    │         │
│ Authentication      │    ◐    │         │         │    ●    │         │
│ Address Validation  │    ◐    │         │         │         │    ●    │
└─────────────────────┴─────────┴─────────┴─────────┴─────────┴─────────┘

Legend: ● Primary Feature Category  ◐ Secondary/Supporting Category
```

## Feature Implementation Overview

### API Endpoint Summary
```
Public Endpoints (No Authentication Required):
├── POST /api/users              # User Registration
├── POST /api/users/login        # User Login
└── GET  /api/welcome           # Welcome/Health Check

Protected Endpoints (Authentication Required):
├── GET    /api/users/:id        # Get User Profile
├── PUT    /api/users/:id        # Update User Profile
├── DELETE /api/users/:id        # Delete User Account
├── POST   /api/accounts         # Create Bank Account
├── POST   /api/accounts/deposit # Deposit Money
├── POST   /api/accounts/withdraw# Withdraw Money
└── POST   /api/accounts/transaction # Transfer Money
```

### Business Logic Integration

#### User Lifecycle Flow
```
Registration → Authentication → Account Creation → Financial Operations
     │              │                │                     │
     ▼              ▼                ▼                     ▼
CEP Validation → JWT Token → Zero Balance → Deposits/Withdrawals/Transfers
```

#### Security Integration
- **Public Features**: Registration, login, welcome
- **Protected Features**: All account and financial operations
- **Authorization**: User-specific resource access control

## Feature Dependencies

### External Dependencies
- **ViaCep API**: Address validation for user registration/updates
- **PostgreSQL**: Data persistence for all features
- **Phoenix Framework**: Web API infrastructure
- **JWT Libraries**: Token-based authentication

### Internal Dependencies
- **User Management** ← Required by → **Account Management**
- **Account Management** ← Required by → **Financial Operations**
- **Authentication** ← Required by → **All Protected Features**
- **Address Validation** ← Used by → **User Management**

## Feature Status and Maturity

### Production-Ready Features ✅
- User Registration and Authentication
- Account Creation and Management
- Financial Operations (Deposits, Withdrawals, Transfers)
- JWT Authentication and Authorization
- Address Validation via ViaCep

### Current Limitations
- **Single Account Per User**: No support for multiple account types
- **Basic Transaction Types**: No scheduled or recurring transactions
- **Limited Reporting**: No transaction history or reporting features
- **No Admin Interface**: No administrative user management
- **Basic Error Handling**: Limited user-friendly error messages

## Feature Roadmap Considerations

### Potential Near-Term Enhancements
1. **Transaction History**: Detailed transaction logs and reporting
2. **Account Statements**: Periodic account statement generation
3. **Multiple Account Types**: Savings, checking, investment accounts
4. **Enhanced Security**: Two-factor authentication, device management
5. **Notification System**: Email/SMS alerts for transactions

### Long-Term Feature Opportunities
1. **Loan Management**: Personal loans and credit facilities
2. **Investment Services**: Investment accounts and portfolio management
3. **Card Management**: Debit/credit card issuance and management
4. **Bill Payments**: Utility and service payment integration
5. **Mobile Banking**: Dedicated mobile application

## Cross-Feature Integration Points

### Data Sharing Between Features
- **User Identity**: Shared across all features for personalization
- **Account Information**: Central to financial operations
- **Authentication State**: Required for all protected operations
- **Address Data**: Used for user verification and compliance

### Business Rule Enforcement
- **Balance Constraints**: Enforced across all financial operations
- **User Uniqueness**: Maintained across user management features
- **Security Policies**: Applied consistently across all features
- **Data Validation**: Standardized across all user input points

For detailed implementation of each feature, see the individual feature documentation files in the `features/` directory.