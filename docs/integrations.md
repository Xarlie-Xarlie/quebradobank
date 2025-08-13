# External Integrations

This document describes how QuebradoBank integrates with external systems, APIs, and cloud services.

## Integration Overview

QuebradoBank integrates with several external systems to provide complete banking functionality:

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                        QuebradoBank Application                             │
└─────────────────────────┬───────────────────────────────────────────────────┘
                          │
    ┌─────────────────────┼─────────────────────┐
    │                     │                     │
    ▼                     ▼                     ▼
┌─────────┐        ┌─────────────┐      ┌─────────────────┐
│ ViaCep  │        │ PostgreSQL  │      │   AWS Cloud     │
│   API   │        │  Database   │      │   Services      │
└─────────┘        └─────────────┘      └─────────────────┘
    │                     │                     │
    ▼                     ▼                     ▼
Address Validation   Data Persistence    Hosting & CI/CD
```

## 1. ViaCep API Integration

### Purpose
Validates Brazilian postal codes (CEP) and provides address information for user registration.

### Integration Details
- **Service**: ViaCep (https://viacep.com.br)
- **Protocol**: HTTP REST API
- **Data Format**: JSON
- **Client Library**: Tesla HTTP client
- **Authentication**: None required (public API)

### API Endpoints Used
- `GET https://viacep.com.br/ws/{cep}/json` - Validates and retrieves address data

### Implementation
- **Location**: `lib/quebrado_bank/via_cep/`
- **Client**: `QuebradoBank.ViaCep.Client`
- **Behavior**: `QuebradoBank.ViaCep.Behaviour` (for testing/mocking)

### Usage Flow
```
User Registration → CEP Validation → ViaCep API → Address Verification → User Creation
```

### Response Handling
- **Success (200)**: Returns address details
- **Not Found**: Invalid CEP returns `{"erro": true}`
- **Bad Request (400)**: Malformed CEP
- **Error Handling**: Graceful fallback with error messages

### Example Integration
```elixir
# Valid CEP
ViaCep.Client.call("65700000")
# => {:ok, %{"cep" => "65700-000", "localidade" => "Bacabal", "uf" => "MA", ...}}

# Invalid CEP  
ViaCep.Client.call("00000000")
# => {:error, :not_found}
```

### Dependencies
- **Features**: User Management (registration/updates)
- **Fallback**: User creation continues even if ViaCep is unavailable
- **Testing**: Mocked via `Mox` for reliable test execution

## 2. PostgreSQL Database

### Purpose
Primary data persistence for all application data.

### Integration Details
- **Service**: PostgreSQL 
- **Protocol**: PostgreSQL wire protocol
- **ORM**: Ecto
- **Connection Pool**: Built-in Ecto connection pooling
- **Environment**: Containerized via Docker

### Database Configuration
- **Development**: Local Docker container
- **Production**: Containerized alongside application
- **Connection**: Environment-based configuration

### Schema Management
- **Migrations**: Ecto migrations in `priv/repo/migrations/`
- **Seeds**: Database seeding via `priv/repo/seeds.exs`
- **Constraints**: Database-level constraints for data integrity

### Key Tables
1. **users** - User account information
2. **accounts** - Bank account data with balance tracking

### Connection Details
```elixir
# Database connection configured in config/runtime.exs
config :quebrado_bank, QuebradoBank.Repo,
  url: database_url,
  pool_size: String.to_integer(System.get_env("POOL_SIZE") || "10")
```

## 3. AWS Cloud Services

### Purpose
Production hosting, deployment, and infrastructure management.

### Services Used

#### AWS EC2
- **Purpose**: Application hosting
- **Configuration**: Single instance deployment
- **Access**: SSH-based deployment via GitHub Actions
- **Security**: SSH key-based authentication

#### Docker Hub Integration
- **Purpose**: Container registry for application images
- **Repository**: `charliecharlie/quebrado_bank:latest`
- **Authentication**: Username/password via GitHub Secrets
- **Updates**: Automated builds on main branch pushes

### Deployment Flow
```
Code Push → GitHub Actions → Docker Build → Docker Hub → AWS EC2 → Container Update
```

### Environment Configuration
Production environment configured via `.env` file with:
- Database connection strings
- Application secrets
- Phoenix secret keys
- External API configurations

## 4. GitHub Integration

### GitHub Actions Workflows

#### Continuous Integration (CI)
- **Trigger**: Push to `develop` branch, PRs to `develop`
- **Services**: PostgreSQL test database
- **Steps**: Dependency installation, compilation, database setup, test execution
- **Purpose**: Code quality assurance

#### Continuous Deployment (CD)  
- **Trigger**: Push to `main` branch
- **Steps**: Docker build, push to registry, AWS deployment
- **Purpose**: Automated production deployments

### Workflow Dependencies
- **Secrets Management**: GitHub Secrets for sensitive data
- **SSH Access**: Automated SSH deployment to AWS
- **Docker Registry**: Integration with Docker Hub

## 5. Development Tools Integration

### Local Development Stack
```
docker-compose up -d postgres  # Local PostgreSQL
mix setup                      # Database setup  
iex -S mix phx.server         # Development server
```

### Testing Environment
- **Test Database**: Isolated PostgreSQL instance
- **Mock Services**: Mox library for external API mocking
- **Factory Pattern**: ExMachina for test data generation

## Integration Dependencies

### Feature Dependencies
- **User Management**: ViaCep API for address validation
- **Account Management**: PostgreSQL for data persistence
- **Financial Operations**: PostgreSQL transactions for data consistency
- **Authentication**: Phoenix Token for JWT generation
- **All Features**: AWS EC2 for production hosting

### Fallback Strategies
- **ViaCep Unavailable**: User creation continues with validation bypass
- **Database Connection**: Connection pooling and retry logic
- **Deployment Failures**: Manual rollback procedures via SSH

### Security Considerations
- **API Keys**: No sensitive API keys required for ViaCep (public API)
- **Database Access**: Restricted via connection strings and network policies
- **AWS Access**: SSH key rotation and access control
- **Secrets Management**: GitHub Secrets for CI/CD credentials

## Monitoring and Health Checks

### External Service Monitoring
- **ViaCep API**: HTTP status monitoring in application logs
- **Database**: Ecto telemetry for connection and query metrics
- **AWS Instance**: SSH availability monitoring

### Error Handling Patterns
- **Circuit Breaker**: For external API failures
- **Retry Logic**: For transient connection issues
- **Graceful Degradation**: Core functionality continues despite external failures

## Future Integration Opportunities

### Potential Additions
- **Payment Processors**: Credit card and payment gateway integration
- **Notification Services**: Email/SMS services for transaction alerts
- **Monitoring Services**: Application performance monitoring (APM)
- **Load Balancing**: AWS ELB for high availability
- **CDN**: CloudFront for static asset delivery

See [Architecture Overview](architecture.md) for system design context and [Features Overview](features.md) for feature-specific integration details.