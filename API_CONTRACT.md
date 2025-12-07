# API Contract Documentation

This document describes the API endpoints used by the Flutter mobile app.

---

## Base URL
```
${API_BASE_URL} - Configured in .env file
```

---

## Authentication

### 1. Google Login
**Endpoint:** `POST /auth/google`

**Request:**
```json
{
  "accessToken": "string"
}
```

**Response:**
```json
{
  "token": "jwt_token_string",
  "user": {
    "id": "string",
    "name": "string",
    "email": "string",
    "avatar": "string",
    "dob": "string",
    "zodiac": "string",
    "mode": "solo",
    "coupleCode": null,
    "coupleRoomId": null,
    "coins": 0
  },
  "needProfile": false
}
```

**Notes:**
- `needProfile: true` means user needs to complete profile
- `needProfile: false` means user can proceed to home

---

### 2. Facebook Login
**Endpoint:** `POST /auth/facebook`

**Request:**
```json
{
  "accessToken": "string"
}
```

**Response:**
```json
{
  "token": "jwt_token_string",
  "user": {
    "id": "string",
    "name": "string",
    "email": "string",
    "avatar": "string",
    "dob": "string",
    "zodiac": "string",
    "mode": "solo",
    "coupleCode": null,
    "coupleRoomId": null,
    "coins": 0
  },
  "needProfile": false
}
```

---

### 3. Update Profile
**Endpoint:** `POST /auth/update-profile`

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{
  "name": "string",
  "dob": "YYYY-MM-DD"
}
```

**Response:**
```json
{
  "user": {
    "id": "string",
    "name": "string",
    "email": "string",
    "avatar": "string",
    "dob": "YYYY-MM-DD",
    "zodiac": "Aries",
    "mode": "solo",
    "coupleCode": null,
    "coupleRoomId": null,
    "coins": 0
  }
}
```

**Notes:**
- Backend automatically calculates zodiac sign from DOB
- Returns updated user object with zodiac

---

## Couple Management

### 4. Generate Couple Code
**Endpoint:** `POST /couple/generate-code`

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{}
```

**Response:**
```json
{
  "code": "ABC123",
  "coupleRoomId": "room_id_string"
}
```

**Notes:**
- Creates a new couple code
- User's mode is updated to "couple"
- Returns unique code and room ID

---

### 5. Join Couple by Code
**Endpoint:** `POST /couple/join-by-code`

**Headers:**
```
Authorization: Bearer {token}
```

**Request:**
```json
{
  "code": "ABC123"
}
```

**Response:**
```json
{
  "coupleRoomId": "room_id_string",
  "message": "Successfully joined couple"
}
```

**Error Response (Invalid Code):**
```json
{
  "statusCode": 400,
  "message": "Invalid or expired couple code"
}
```

**Notes:**
- Validates code exists and is not expired
- Links user to couple room
- Updates user's mode to "couple"

---

### 6. Get Couple Info
**Endpoint:** `GET /couple/info`

**Headers:**
```
Authorization: Bearer {token}
```

**Response:**
```json
{
  "id": "couple_id",
  "user1Id": "user_id_1",
  "user2Id": "user_id_2",
  "user1Name": "User 1",
  "user2Name": "User 2",
  "user1Avatar": "url",
  "user2Avatar": "url",
  "inviteCode": "ABC123",
  "loveScore": 50,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

---

## WebSocket Events

### Connection
**URL:** `${API_BASE_URL}`

**Connection Options:**
```javascript
{
  transports: ['websocket'],
  auth: {
    token: "jwt_token"
  },
  extraHeaders: {
    Authorization: "Bearer jwt_token"
  }
}
```

---

### Client → Server Events

#### 1. Join Couple Room
**Event:** `join-couple-room`

**Payload:**
```json
{
  "coupleRoomId": "room_id_string"
}
```

---

#### 2. Send Message
**Event:** `send-couple-message`

**Payload:**
```json
{
  "coupleRoomId": "room_id_string",
  "message": "Hello!"
}
```

---

#### 3. Feed Pet
**Event:** `feed-pet`

**Payload:**
```json
{
  "coupleRoomId": "room_id_string"
}
```

---

### Server → Client Events

#### 1. Couple Message
**Event:** `couple-message`

**Payload:**
```json
{
  "senderId": "user_id",
  "senderName": "User Name",
  "message": "Hello!",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

---

#### 2. Partner Joined
**Event:** `partner-joined`

**Payload:**
```json
{
  "userId": "partner_user_id",
  "userName": "Partner Name"
}
```

---

#### 3. Partner Left
**Event:** `partner-left`

**Payload:**
```json
{
  "userId": "partner_user_id",
  "userName": "Partner Name"
}
```

---

#### 4. Pet Fed
**Event:** `pet-fed`

**Payload:**
```json
{
  "userId": "feeder_user_id",
  "userName": "Feeder Name",
  "petHunger": 80
}
```

---

#### 5. Love Score Updated
**Event:** `love-score-updated`

**Payload:**
```json
{
  "loveScore": 55,
  "reason": "message_sent"
}
```

---

## Error Responses

### Standard Error Format
```json
{
  "statusCode": 400,
  "message": "Error message" | ["Error 1", "Error 2"],
  "error": "Bad Request"
}
```

### Common Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request (validation error)
- `401` - Unauthorized (invalid/missing token)
- `404` - Not Found
- `500` - Internal Server Error

---

## Authentication Flow

### Token Management
1. Client receives `token` from login endpoints
2. Client stores token in local storage
3. Client includes token in all subsequent requests:
   ```
   Authorization: Bearer {token}
   ```
4. Backend validates token on each request
5. Token is also used for WebSocket authentication

---

## Data Models

### User Object
```typescript
{
  id: string;
  name?: string;
  email?: string;
  avatar?: string;
  dob?: string;           // Format: YYYY-MM-DD
  zodiac?: string;        // Calculated by backend
  mode: 'solo' | 'couple';
  coupleCode?: string;
  coupleRoomId?: string;
  coins: number;
}
```

### Couple Object
```typescript
{
  id: string;
  user1Id: string;
  user2Id: string;
  user1Name?: string;
  user2Name?: string;
  user1Avatar?: string;
  user2Avatar?: string;
  inviteCode: string;
  loveScore: number;
  createdAt?: string;
}
```

---

## Request/Response Examples

### Complete Login Flow

#### Step 1: Google Login
```bash
POST /auth/google
Content-Type: application/json

{
  "accessToken": "google_access_token_here"
}
```

**Response (New User):**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": "user123",
    "email": "user@example.com",
    "mode": "solo",
    "coins": 0
  },
  "needProfile": true
}
```

#### Step 2: Complete Profile
```bash
POST /auth/update-profile
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "name": "John Doe",
  "dob": "1995-06-15"
}
```

**Response:**
```json
{
  "user": {
    "id": "user123",
    "name": "John Doe",
    "email": "user@example.com",
    "dob": "1995-06-15",
    "zodiac": "Gemini",
    "mode": "solo",
    "coins": 0
  }
}
```

---

### Complete Couple Flow

#### Step 1: Generate Code
```bash
POST /couple/generate-code
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{}
```

**Response:**
```json
{
  "code": "LOVE2024",
  "coupleRoomId": "room_abc123"
}
```

#### Step 2: Partner Joins
```bash
POST /couple/join-by-code
Authorization: Bearer partner_token_here...
Content-Type: application/json

{
  "code": "LOVE2024"
}
```

**Response:**
```json
{
  "coupleRoomId": "room_abc123",
  "message": "Successfully joined couple"
}
```

#### Step 3: Connect WebSocket
```javascript
// Both users connect to WebSocket
socket.emit('join-couple-room', {
  coupleRoomId: 'room_abc123'
});
```

#### Step 4: Send Message
```javascript
socket.emit('send-couple-message', {
  coupleRoomId: 'room_abc123',
  message: 'Hello partner!'
});
```

**Received by Partner:**
```javascript
socket.on('couple-message', (data) => {
  // data = {
  //   senderId: 'user123',
  //   senderName: 'John Doe',
  //   message: 'Hello partner!',
  //   timestamp: '2024-01-01T12:00:00.000Z'
  // }
});
```

---

## Notes

### Date Format
- All dates use ISO 8601 format: `YYYY-MM-DD` or `YYYY-MM-DDTHH:mm:ss.sssZ`
- DOB specifically uses: `YYYY-MM-DD`

### Zodiac Calculation
- Backend automatically calculates zodiac sign from DOB
- Client doesn't need to calculate zodiac

### Mode Changes
- User starts in `solo` mode
- Changes to `couple` mode when generating or joining couple
- Backend handles mode updates automatically

### Token Expiration
- Tokens may expire (check backend configuration)
- Client should handle 401 responses by redirecting to login

### WebSocket Reconnection
- Client should implement reconnection logic
- On reconnect, emit `join-couple-room` again

---

## Testing with cURL

### Test Login
```bash
curl -X POST http://localhost:3000/auth/google \
  -H "Content-Type: application/json" \
  -d '{"accessToken":"test_token"}'
```

### Test Generate Code
```bash
curl -X POST http://localhost:3000/couple/generate-code \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{}'
```

### Test Join Couple
```bash
curl -X POST http://localhost:3000/couple/join-by-code \
  -H "Authorization: Bearer PARTNER_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"code":"LOVE2024"}'
```

---

## Contact Backend Team

If any endpoints don't match this documentation or you need additional endpoints, contact the backend team with:
- Endpoint URL
- Expected request/response
- Use case description

