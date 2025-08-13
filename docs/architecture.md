# Architecture Overview

## System Architecture

QuebradoBank is a cloud-native banking API built with Elixir/Phoenix, designed for scalability and reliability. The system follows a layered architecture pattern with clear separation of concerns.

### High-Level Architecture Diagram

```mermaid
graph TB
    Client[Client Applications<br/>Web, Mobile, API Consumers]
    
    subgraph AWS["AWS EC2 Instance"]
        subgraph Docker["Docker Container"]
            subgraph Phoenix["Phoenix Web Server"]
                Router[Router]
                Controllers[Controllers]
                AuthMW[Auth Middleware]
                Contexts[Contexts]
                Schemas[Schemas]
                BusinessLogic[Business Logic]
                Ecto[Ecto]
                Telemetry[Telemetry]
                ExtClients[External Clients]
            end
        end
    end
    
    subgraph DB["PostgreSQL Database"]
        Users[Users Table]
        Accounts[Accounts Table]
    end
    
    subgraph APIs["External APIs"]
        ViaCep[ViaCep API]
        FutureAPIs[Future APIs]
    end
    
    Client -->|HTTPS/JSON API| Phoenix
    Phoenix --> DB
    Phoenix --> APIs
```

## Infrastructure Components

### Cloud Infrastructure
- **AWS EC2**: Production hosting environment
- **Docker Container**: Application containerization
- **PostgreSQL**: Primary database (containerized)
- **GitHub Actions**: CI/CD pipeline automation
- **Docker Hub**: Container registry

### Application Stack
- **Elixir/Phoenix**: Web framework and runtime
- **Ecto**: Database ORM and query builder
- **Cowboy**: HTTP server
- **Phoenix Token**: JWT authentication
- **Tesla**: HTTP client for external APIs
- **Argon2**: Password hashing

## Component Interactions

### Request Flow
1. **Client Request** → API endpoint via HTTPS
2. **Phoenix Router** → Routes to appropriate controller
3. **Auth Middleware** → Validates JWT tokens (for protected routes)
4. **Controller** → Processes request and calls business logic
5. **Context Layer** → Orchestrates business operations
6. **Ecto/Database** → Persists or retrieves data
7. **External APIs** → ViaCep for address validation (when needed)
8. **Response** → JSON response back to client

### Data Flow Architecture
```mermaid
graph LR
    Client --> Router
    Router --> Auth[Auth]
    Auth --> Controller
    Controller --> Context
    Context --> Schema[Schema/Ecto]
    Schema --> Database
    
    Context --> BusinessLogic[Business Logic]
    BusinessLogic --> ExternalAPIs[External APIs]
    BusinessLogic --> JSONView[JSON View]
    JSONView --> JSONResponse[JSON Response]
    JSONResponse --> Client
```

### Security Layers
1. **HTTPS Encryption** - All communication encrypted
2. **JWT Authentication** - Token-based auth for protected endpoints  
3. **Input Validation** - Ecto changesets validate all inputs
4. **SQL Injection Protection** - Ecto parameterized queries
5. **Password Security** - Argon2 hashing for user passwords

## Deployment Architecture

### CI/CD Pipeline
```mermaid
graph LR
    DevPush[Developer Push] --> GitHub
    GitHub --> CITests[CI Tests]
    CITests --> BuildDocker[Build Docker]
    BuildDocker --> PushHub[Push to Hub]
    PushHub --> DeployAWS[Deploy to AWS]
    
    DevPush --> GitCommit[Git Commit]
    GitHub --> Actions
    CITests --> TestSuite[Test Suite]
    BuildDocker --> Container
    PushHub --> Registry
    DeployAWS --> EC2Update[EC2 Update]
```

### Production Environment
- **AWS EC2 Instance** running Docker containers
- **Docker Compose** orchestration for multi-service setup
- **PostgreSQL Container** for data persistence
- **Application Container** running Phoenix server
- **Automated Deployment** via GitHub Actions on main branch pushes

## Database Design

### Entity Relationship
```mermaid
erDiagram
    Users {
        int id PK
        string name
        string email "unique"
        string password_hash
        string cep
        datetime created_at
        datetime updated_at
    }
    
    Accounts {
        int id PK
        decimal balance
        int user_id FK
        datetime created_at
        datetime updated_at
    }
    
    Users ||--|| Accounts : "1:1 relationship"
```

### Key Constraints
- One user can have exactly one account (1:1 relationship)
- Account balance must be non-negative (check constraint)
- Email addresses must be unique across users
- User-Account relationship enforced by foreign key constraint

## Scalability Considerations

### Current Architecture Benefits
- **Stateless Application** - Easy horizontal scaling
- **Database Transactions** - ACID compliance for financial operations  
- **External API Isolation** - ViaCep failures don't break core functionality
- **Container-Based** - Easy deployment and scaling

### Future Scaling Options
- Load balancer for multiple application instances
- Database read replicas for improved performance
- Redis for session/cache management
- Message queues for async processing
- Microservices decomposition for specific domains

## Monitoring and Observability

- **Telemetry Integration** - Built-in Phoenix telemetry
- **Database Metrics** - Query timing and performance tracking
- **HTTP Metrics** - Request/response timing and status codes
- **Live Dashboard** - Development environment monitoring (when enabled)

See [External Integrations](integrations.md) for details on external service dependencies and [Features Overview](features.md) for detailed feature architecture.