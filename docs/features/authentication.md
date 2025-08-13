# Authentication & Authorization Feature

## Overview

The Authentication & Authorization feature provides secure access control for QuebradoBank API. It implements JWT token-based authentication, request authorization, and ensures that users can only access their own resources. This feature is fundamental to system security and user privacy.

## Feature Purpose

Authentication & Authorization enables:
- Secure user login with JWT token generation
- Protected API endpoint access control
- User identity verification for all requests
- Resource ownership authorization
- Session management through stateless tokens

This feature ensures that all sensitive banking operations are properly secured and that user data remains private and protected.

## Architecture Integration

### Security Layer Diagram
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           Client Application                                │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │ HTTP Requests with JWT
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                        Phoenix Router                                      │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────────────────────┐
│                    Auth Pipeline                                           │
│  ┌─────────────────┐ ┌─────────────────┐ ┌─────────────────────────────┐   │
│  │   JWT Token     │ │  Auth Middleware│ │    User Authorization       │   │
│  │  Verification   │ │   (Plug.Auth)   │ │      (Resource Access)      │   │
│  └─────────────────┘ └─────────────────┘ └─────────────────────────────┘   │
└──────────────────────────┬──────────────────────────────────────────────────┘
                           │ Authorized Request
                           ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      Controller Layer                                      │
│                   (Protected Endpoints)                                    │
└─────────────────────────────────────────────────────────────────────────────┘
```

### Request Flow
```
Client Request → Router → Auth Pipeline → Controller → Business Logic
      │            │           │             │             │
      ▼            ▼           ▼             ▼             ▼
   JWT Token → Route Match → Token Valid? → User Access → Resource Check
      │            │           │             │             │
      └────────────┴───────────┴─────────────┴─────────────┘
                              │
                              ▼
                        Success/Failure
```

## Key Workflows

### 1. Token Generation Workflow (Login)

```
User Login Request
         │
         ▼
┌─────────────────┐
│ Credential Check│
│ (Email/Password)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ User Lookup     │
│ (Database Query)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Password Verify │
│ (Argon2 Check)  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ JWT Generation  │
│ (Phoenix Token) │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Token Response  │
│ (Client Storage)│
└─────────────────┘
```

**Input/Output:**
- **Input**: `email`, `password`
- **Output**: JWT token + user information
- **Error Cases**: Invalid credentials, user not found

### 2. Token Validation Workflow (Auth Middleware)

```
Protected Endpoint Request
         │
         ▼
┌─────────────────┐
│ Extract Token   │
│ (Auth Header)   │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Token Format    │
│ Check (Bearer)  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ JWT Verification│
│ (Signature/Exp) │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ User ID Extract │
│ (Token Payload) │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Request Context │
│ (User ID Assign)│
└─────────────────┘
         │
         ▼
   Continue to Controller
```

**Process:**
- Extract `Authorization: Bearer <token>` header
- Verify JWT signature and expiration
- Extract user ID from token payload
- Assign user ID to request context

### 3. Resource Authorization Workflow

```
Controller Action Request
         │
         ▼
┌─────────────────┐
│ User ID from    │
│ Request Context │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Resource Lookup │
│ (Database Query)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Ownership Check │
│ (User ID Match) │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Access Decision │
│ (Allow/Deny)    │
└─────────────────┘
```

**Authorization Rules:**
- User can only access their own profile
- User can only operate on their own account
- User can only view their own transaction history

## Implementation Details

### Core Components

#### 1. JWT Token Module (`lib/quebrado_bank_web/token.ex`)
Handles token generation and verification using Phoenix Token.

```elixir
defmodule QuebradoBankWeb.Token do
  alias Phoenix.Token
  alias QuebradoBankWeb.Endpoint
  
  @sign_salt "quebrado"

  def sign(%User{id: user_id}) do
    Token.sign(Endpoint, @sign_salt, %{user_id: user_id})
  end

  def verify(token) do
    Token.verify(Endpoint, @sign_salt, token)
  end
end
```

**Features:**
- Stateless JWT tokens
- Configurable expiration
- Secure salt-based signing
- User ID payload

#### 2. Authentication Middleware (`lib/quebrado_bank_web/plugs/auth.ex`)
Protects endpoints requiring authentication.

```elixir
defmodule QuebradoBankWeb.Plugs.Auth do
  import Plug.Conn
  
  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, %{user_id: user_id}} <- Token.verify(token) do
      assign(conn, :user_id, user_id)
    else
      _ -> 
        conn
        |> put_status(:unauthorized)
        |> render_error(:unauthorized)
        |> halt()
    end
  end
end
```

**Functionality:**
- Bearer token extraction
- JWT verification
- User ID assignment to connection
- Unauthorized request blocking

#### 3. Router Pipeline Configuration (`lib/quebrado_bank_web/router.ex`)
Defines public and protected endpoint groups.

```elixir
# Public endpoints (no authentication)
scope "/api", QuebradoBankWeb do
  pipe_through :api
  
  post "/users", UsersController, :create
  post "/users/login", UsersController, :login
  get "/welcome", WelcomeController, :index
end

# Protected endpoints (authentication required)
scope "/api", QuebradoBankWeb do
  pipe_through [:api, :auth]
  
  resources "/users", UsersController, only: [:update, :delete, :show]
  post "/accounts", AccountsController, :create
  post "/accounts/transaction", AccountsController, :transaction
  post "/accounts/withdraw", AccountsController, :withdraw
  post "/accounts/deposit", AccountsController, :deposit
end
```

### Authentication Flow

#### Login Process
```http
POST /api/users/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Success Response:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 123,
    "name": "John Doe",
    "email": "user@example.com",
    "cep": "12345-678"
  }
}
```

**Error Response:**
```json
{
  "error": "unauthorized"
}
```

#### Protected Request Process
```http
GET /api/users/123
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Success Response:**
```json
{
  "id": 123,
  "name": "John Doe", 
  "email": "user@example.com",
  "cep": "12345-678",
  "account": {
    "id": 456,
    "balance": "150.75"
  }
}
```

## Security Implementation

### JWT Token Security

#### Token Structure
```json
{
  "header": {
    "alg": "HS256",
    "typ": "JWT"
  },
  "payload": {
    "user_id": 123,
    "iat": 1693087200,
    "exp": 1693173600
  },
  "signature": "..."
}
```

#### Security Features
- **HMAC SHA256 Signing**: Prevents token tampering
- **Expiration Time**: Configurable token lifetime
- **Salt-based Signing**: Additional security layer
- **Stateless Design**: No server-side session storage

### Password Security
```elixir
# Password verification in login
def verify_password(password, hash) do
  Argon2.verify_pass(password, hash)
end
```

**Security Measures:**
- Argon2 password hashing (industry standard)
- Salt-based hashing prevents rainbow table attacks
- Secure password comparison prevents timing attacks

### Request Security

#### HTTPS Enforcement
- All communication encrypted in transit
- Bearer tokens protected from interception
- Secure cookie options when applicable

#### Input Validation
- All request parameters validated
- SQL injection prevention via Ecto
- XSS prevention via proper output encoding

## Authorization Patterns

### User Resource Authorization
```elixir
# In controller actions
def show(conn, %{"id" => user_id}) do
  current_user_id = conn.assigns.user_id
  
  if user_id == to_string(current_user_id) do
    # User can access their own profile
    user = Users.get(user_id)
    render(conn, :show, user: user)
  else
    # Unauthorized access attempt
    conn
    |> put_status(:forbidden)
    |> render(:error, error: "access denied")
  end
end
```

### Account Resource Authorization
```elixir
# In financial operations
def deposit(conn, params) do
  user_id = conn.assigns.user_id
  
  # User can only deposit to their own account
  with {:ok, account} <- Accounts.deposit(params, user_id) do
    render(conn, :show, account: account)
  end
end
```

### Automatic Authorization
Many operations automatically ensure user ownership:
- Account lookups filter by user ID
- Database queries include user ID in WHERE clauses
- No cross-user data access possible

## Error Handling

### Authentication Errors
```elixir
# Missing token
conn |> put_status(:unauthorized) |> render(:error, error: "token required")

# Invalid token  
conn |> put_status(:unauthorized) |> render(:error, error: "invalid token")

# Expired token
conn |> put_status(:unauthorized) |> render(:error, error: "token expired")
```

### Authorization Errors
```elixir
# Resource not owned by user
conn |> put_status(:forbidden) |> render(:error, error: "access denied")

# Insufficient permissions
conn |> put_status(:forbidden) |> render(:error, error: "insufficient permissions")
```

### Security Error Handling
- **Generic Error Messages**: Prevent information disclosure
- **No User Enumeration**: Same error for invalid user/password
- **Rate Limiting**: Could be added to prevent brute force attacks

## Testing Strategy

### Authentication Testing
```elixir
# Valid token testing
test "authenticated request succeeds" do
  token = generate_valid_token(user)
  
  conn = 
    build_conn()
    |> put_req_header("authorization", "Bearer #{token}")
    |> get("/api/users/#{user.id}")
    
  assert json_response(conn, 200)
end

# Invalid token testing  
test "invalid token returns unauthorized" do
  conn = 
    build_conn()
    |> put_req_header("authorization", "Bearer invalid_token")
    |> get("/api/users/123")
    
  assert json_response(conn, 401)
end
```

### Authorization Testing
```elixir
# User resource access testing
test "user can access own profile" do
  user = insert(:user)
  token = generate_token(user)
  
  conn = authorized_request(token, "/api/users/#{user.id}")
  assert json_response(conn, 200)
end

test "user cannot access other user's profile" do
  user1 = insert(:user)
  user2 = insert(:user)
  token = generate_token(user1)
  
  conn = authorized_request(token, "/api/users/#{user2.id}")
  assert json_response(conn, 403)
end
```

## Performance Considerations

### Token Verification Performance
- **Stateless Verification**: No database lookup required
- **HMAC Performance**: Fast cryptographic verification
- **Memory Efficiency**: No server-side session storage

### Caching Opportunities
- **User Data Caching**: Cache user info after token verification
- **Token Blacklisting**: Could implement for logout functionality
- **Rate Limiting**: Implement to prevent abuse

## Monitoring and Security Metrics

### Authentication Metrics
- **Login Success Rate**: Percentage of successful logins
- **Token Usage**: Active token count and lifetime
- **Failed Authentication**: Attempted unauthorized access
- **Token Expiration**: Token refresh patterns

### Security Monitoring
- **Suspicious Activity**: Multiple failed login attempts
- **Token Anomalies**: Unusual token usage patterns
- **Access Patterns**: Resource access frequency and timing

## Future Enhancements

### Near-Term Security Improvements
1. **Refresh Tokens**: Long-lived refresh tokens for better UX
2. **Token Revocation**: Ability to invalidate tokens (logout)
3. **Rate Limiting**: Prevent brute force and abuse
4. **Account Lockout**: Temporary lockout after failed attempts

### Advanced Security Features
1. **Two-Factor Authentication**: SMS or app-based 2FA
2. **Device Management**: Track and manage user devices
3. **Session Management**: Active session monitoring and control
4. **Anomaly Detection**: Unusual login pattern detection

### Compliance Features
1. **Audit Logging**: Complete authentication event logging
2. **Compliance Reports**: Access logs for regulatory requirements
3. **Data Privacy**: GDPR/LGPD compliant user data handling
4. **Security Headers**: Additional HTTP security headers

## Configuration and Environment

### Token Configuration
```elixir
# config/config.exs
config :quebrado_bank, QuebradoBankWeb.Token,
  token_lifetime: {2, :hours},  # Token expires in 2 hours
  sign_salt: "secure_salt_value"
```

### Security Configuration
```elixir
# config/prod.exs
config :quebrado_bank, QuebradoBankWeb.Endpoint,
  force_ssl: [rewrite_on: [:x_forwarded_proto]],
  secure_cookie_flag: true
```

## Related Documentation

- [User Management](user-management.md) - User login and profile access
- [Account Management](account-management.md) - Account ownership authorization
- [Financial Operations](financial-operations.md) - Transaction authorization
- [Architecture Overview](../architecture.md) - Security architecture
- [External Integrations](../integrations.md) - API security considerations