# Financial Operations Feature

## Overview

The Financial Operations feature implements the core banking transactions in QuebradoBank: deposits, withdrawals, and account-to-account transfers. This feature ensures financial data integrity, implements business rules for money movement, and provides atomic transaction processing.

## Feature Purpose

Financial Operations enable users to:
- Deposit money into their accounts
- Withdraw money from their accounts  
- Transfer money between different user accounts
- Maintain accurate account balances with transaction integrity

This feature forms the heart of the banking system, providing the essential money movement capabilities that customers expect from a banking platform.

## Architecture Integration

### System Context
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ Authentication  │───▶│Financial Ops    │───▶│Account Mgmt     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
   User Identity           Transaction Proc.        Balance Updates
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 ▼
                          ┌─────────────────┐
                          │   PostgreSQL    │
                          │  (ACID Trans.)  │
                          └─────────────────┘
```

### Transaction Flow Diagram
```
┌─────────────────┐
│   User Request  │
│  (via API)      │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Authentication  │
│ & Authorization │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Input Validation│
│ & Business Rules│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Account Lookup  │
│ & Verification  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Balance Check   │
│ (if required)   │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Database Trans. │
│ (Atomic Update) │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Success Response│
│ & Updated Data  │
└─────────────────┘
```

## Key Workflows

### 1. Deposit Workflow

```
Deposit Request
         │
         ▼
┌─────────────────┐
│ User Auth Check │
│ (JWT Token)     │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Amount Validation│
│ (Positive Value)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Account Lookup  │
│ (User's Account)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Balance Update  │
│ (Add Amount)    │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Database Commit │
│ (New Balance)   │
└─────────────────┘
         │
         ▼
   Success Response
```

**Input/Output:**
- **Input**: `amount` (positive decimal)
- **Output**: Updated account with new balance
- **Error Cases**: Invalid amount, account not found, database errors

### 2. Withdrawal Workflow

```
Withdrawal Request
         │
         ▼
┌─────────────────┐
│ User Auth Check │
│ (JWT Token)     │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Amount Validation│
│ (Positive Value)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Account Lookup  │
│ (User's Account)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Sufficient Funds│
│ Check (Balance) │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Balance Update  │
│ (Subtract Amount)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Database Commit │
│ (New Balance)   │
└─────────────────┘
         │
         ▼
   Success Response
```

**Input/Output:**
- **Input**: `amount` (positive decimal)
- **Output**: Updated account with new balance  
- **Error Cases**: Insufficient funds, invalid amount, account not found

### 3. Transfer Workflow

```
Transfer Request
         │
         ▼
┌─────────────────┐
│ User Auth Check │
│ (JWT Token)     │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Input Validation│
│ (Accounts & Amt)│
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Account Lookups │
│ (Both Accounts) │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Self-Transfer   │
│ Prevention      │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Sufficient Funds│
│ Check (Source)  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Atomic Transfer │
│ (Multi Update)  │
└─────────────────┘
         │
         ▼
┌─────────────────┐
│ Database Commit │
│ (Both Balances) │
└─────────────────┘
         │
         ▼
   Transfer Complete
```

**Input/Output:**
- **Input**: `origin_account`, `destination_account`, `amount`
- **Output**: Both updated accounts with new balances
- **Error Cases**: Same account transfer, insufficient funds, account not found

## Implementation Details

### Core Components

#### 1. Deposit Module (`lib/quebrado_bank/accounts/deposit.ex`)
Handles single-account balance increases.

```elixir
def call(%{"value" => value}, user_id) do
  with true <- Account.balance_is_valid?(value),
       %Account{} = account <- get_user_account(user_id) do
    account
    |> update_balance(:add, value)
    |> Repo.update()
  end
end
```

#### 2. Withdrawal Module (`lib/quebrado_bank/accounts/withdraw.ex`)  
Handles single-account balance decreases with validation.

```elixir
def call(%{"value" => value}, user_id) do
  with true <- Account.balance_is_valid?(value),
       %Account{} = account <- get_user_account(user_id),
       true <- sufficient_funds?(account, value) do
    account
    |> update_balance(:subtract, value)
    |> Repo.update()
  end
end
```

#### 3. Transaction Module (`lib/quebrado_bank/accounts/transaction.ex`)
Handles atomic transfers between accounts using database transactions.

```elixir
def call(%{
  "origin_account" => from_id,
  "destination_account" => to_id,
  "value" => value
}) do
  with true <- Account.balance_is_valid?(value),
       accounts <- validate_accounts(from_id, to_id) do
    Multi.new()
    |> withdraw(accounts.from, value)
    |> deposit(accounts.to, value)
    |> Repo.transaction()
  end
end
```

### API Endpoints

#### Deposit Endpoint
```http
POST /api/accounts/deposit
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "value": "100.50"
}
```

**Response (Success):**
```json
{
  "id": 456,
  "balance": "250.75",
  "user_id": 123,
  "updated_at": "2023-08-26T22:30:15Z"
}
```

#### Withdrawal Endpoint
```http
POST /api/accounts/withdraw
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "value": "50.25"
}
```

**Response (Success):**
```json
{
  "id": 456,
  "balance": "200.50",
  "user_id": 123,
  "updated_at": "2023-08-26T22:35:20Z"
}
```

#### Transfer Endpoint
```http
POST /api/accounts/transaction
Authorization: Bearer <jwt_token>
Content-Type: application/json

{
  "origin_account": 456,
  "destination_account": 789,
  "value": "75.00"
}
```

**Response (Success):**
```json
{
  "withdraw": {
    "id": 456,
    "balance": "125.50",
    "user_id": 123,
    "updated_at": "2023-08-26T22:40:10Z"
  },
  "deposit": {
    "id": 789,
    "balance": "175.00",
    "user_id": 456,
    "updated_at": "2023-08-26T22:40:10Z"
  }
}
```

## Business Logic Implementation

### Amount Validation
```elixir
def balance_is_valid?(value) do
  case Decimal.cast(value) do
    {:ok, decimal_value} -> Decimal.gt?(decimal_value, Decimal.new("0"))
    :error -> false
  end
end
```

**Rules Applied:**
- Must be convertible to decimal
- Must be greater than zero
- No upper limit currently enforced

### Sufficient Funds Checking
```elixir
defp sufficient_funds?(%Account{balance: balance}, withdrawal_amount) do
  new_balance = Decimal.sub(balance, withdrawal_amount)
  Decimal.gte?(new_balance, Decimal.new("0"))
end
```

**Logic:**
- Calculate resulting balance after withdrawal
- Ensure result would be non-negative
- Prevent overdraft situations

### Atomic Transfer Implementation
```elixir
defp withdraw(multi, %Account{balance: balance} = account, value) do
  new_balance = Decimal.sub(balance, value)
  changeset = Account.changeset(account, %{balance: new_balance})
  Multi.update(multi, :withdraw, changeset)
end

defp deposit(multi, %Account{balance: balance} = account, value) do
  new_balance = Decimal.add(balance, value)
  changeset = Account.changeset(account, %{balance: new_balance})
  Multi.update(multi, :deposit, changeset)
end
```

**Atomicity Guarantees:**
- Both operations succeed or both fail
- No partial transfers possible
- Database-level transaction isolation

## Security and Authorization

### Access Control
- **Authentication Required**: All endpoints require valid JWT token
- **Account Ownership**: Users can only operate on their own accounts
- **Transfer Authorization**: Source account must belong to authenticated user

### Input Validation
```elixir
# Amount validation
with true <- Account.balance_is_valid?(value) do
  # Process transaction
else
  false -> {:error, "value is not valid"}
end

# Account validation for transfers
with {_, %Account{} = from_account} <- {from_id, Repo.get(Account, from_id)},
     {_, %Account{} = to_account} <- {to_id, Repo.get(Account, to_id)} do
  # Process transfer
else
  {^from_id, nil} -> {:error, "origin account not found"}
  {^to_id, nil} -> {:error, "destination account not found"}
end
```

### Business Rule Enforcement
- **Self-Transfer Prevention**: Cannot transfer to same account
- **Positive Amounts Only**: All amounts must be positive
- **Balance Constraints**: Database-level negative balance prevention

## Error Handling

### Validation Errors
- **Invalid Amount**: "value is not valid"
- **Insufficient Funds**: Database constraint error with custom message
- **Account Not Found**: "account not found" (generic for security)
- **Self Transfer**: "you can't transfer to the same account!"

### Database Errors
- **Constraint Violations**: Handled gracefully with user-friendly messages
- **Transaction Failures**: Automatic rollback on any step failure
- **Connection Issues**: Standard Ecto error handling

### Edge Case Handling
```elixir
# Malformed request handling
def call(_invalid_params), do: {:error, :unprocessable_entity}

# Same account transfer prevention  
def call(%{
  "origin_account" => account_id,
  "destination_account" => account_id,
  "value" => _value
}), do: {:error, "you can't transfer to the same account!"}
```

## Performance Considerations

### Database Optimization
- **Connection Pooling**: Ecto manages connection pool for concurrent transactions
- **Transaction Isolation**: Proper isolation levels for financial operations
- **Index Usage**: Primary key lookups for account retrieval

### Concurrency Handling
- **Database Locking**: Automatic row-level locking during updates
- **Transaction Serialization**: Database ensures transaction consistency
- **Retry Logic**: Could be added for transient failures

### Decimal Precision
```elixir
# Precise financial calculations
balance = Decimal.new("150.75")        # Exact representation
deposit_amount = Decimal.new("25.50")  # No floating point errors
new_balance = Decimal.add(balance, deposit_amount)  # Precise arithmetic
```

## Testing Strategy

### Unit Testing
- **Amount Validation**: Positive/negative/zero/invalid values
- **Balance Calculations**: Decimal arithmetic accuracy
- **Business Logic**: Rule enforcement testing

### Integration Testing
- **API Endpoints**: Full request/response cycle
- **Database Transactions**: Multi-step operation testing
- **Error Scenarios**: Invalid input and edge case handling

### Concurrency Testing
- **Simultaneous Transactions**: Race condition testing
- **Balance Consistency**: Concurrent operation integrity
- **Deadlock Prevention**: Database locking behavior

## Monitoring and Observability

### Transaction Metrics
- **Success Rates**: Percentage of successful operations
- **Error Rates**: Categorized error frequency
- **Response Times**: Operation performance tracking
- **Volume Metrics**: Transaction count and value totals

### Business Metrics
- **Transaction Types**: Deposit/withdrawal/transfer distribution
- **Average Amounts**: Transaction size analysis
- **User Activity**: Transaction frequency per user
- **Balance Trends**: System-wide balance changes

## Future Enhancements

### Near-Term Improvements
1. **Transaction History**: Detailed transaction logging and retrieval
2. **Transaction Limits**: Daily/monthly limits per user
3. **Batch Operations**: Multiple transactions in single request
4. **Transaction Fees**: Configurable fee structures

### Advanced Features
1. **Scheduled Transactions**: Recurring payments and transfers
2. **Transaction Reversal**: Ability to reverse transactions
3. **Multi-Currency**: Support for different currencies
4. **Transaction Categories**: Categorization and tagging

### Technical Improvements
1. **Async Processing**: Queue-based transaction processing
2. **Event Sourcing**: Complete transaction event trail
3. **Real-time Notifications**: Instant transaction alerts
4. **Advanced Analytics**: Transaction pattern analysis

## Related Documentation

- [Account Management](account-management.md) - Account balance and structure
- [Authentication](authentication.md) - Transaction security and authorization
- [User Management](user-management.md) - User-account relationships
- [Business Logic](../business-logic.md) - Financial business rules
- [Architecture Overview](../architecture.md) - Transaction system design