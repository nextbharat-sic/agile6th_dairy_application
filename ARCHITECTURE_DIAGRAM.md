# Kisan Diary - Architecture Diagram

## System Architecture Overview

```mermaid
graph TB
    subgraph "Kisan Diary Application"
        subgraph "Frontend Layer"
            A[Flutter UI Framework] --> B[Presentation Layer]
            B --> C[State Management - Provider]
            C --> D[Widgets & Screens]
            D --> E[Custom Components]
        end
        
        subgraph "Business Logic Layer"
            F[Providers] --> G[Services]
            G --> H[Repositories]
            H --> I[Entities]
            I --> J[Validation Logic]
        end
        
        subgraph "Data Layer"
            K[Models] --> L[Firebase Firestore]
            L --> M[Firebase Auth]
            M --> N[Firebase Storage]
            N --> O[Local Storage - SharedPreferences]
        end
        
        subgraph "External Services"
            P[Google Sign-In API] --> Q[Firebase Services]
            Q --> R[Firebase Cloud Functions]
            R --> S[Firebase Analytics]
        end
    end
    
    subgraph "Infrastructure & Backend"
        T[Firebase Console] --> U[Firestore Database]
        U --> V[Authentication Service]
        V --> W[Storage Service]
        W --> X[Cloud Functions]
        X --> Y[Analytics Dashboard]
    end
    
    subgraph "Platform Support"
        Z[Android] --> AA[Google Play Store]
        BB[iOS] --> CC[App Store]
        DD[Web] --> EE[Web Hosting]
    end
    
    A --> F
    F --> K
    K --> T
    P --> V
    A --> Z
    A --> BB
    A --> DD
```

## Detailed Component Architecture

```mermaid
graph LR
    subgraph "Frontend Components"
        A[Main App] --> B[Authentication Wrapper]
        B --> C[Main Navigation]
        C --> D[Dashboard Screen]
        C --> E[Milk Entry Screen]
        C --> F[Expenses Screen]
        C --> G[Reports Screen]
        C --> H[Settings Screen]
    end
    
    subgraph "State Management"
        I[AuthProvider] --> J[User State]
        K[ExpensesProvider] --> L[Expense State]
        M[LanguageProvider] --> N[Locale State]
        O[NavigationProvider] --> P[Navigation State]
    end
    
    subgraph "Data Flow"
        Q[UI Events] --> R[Provider Actions]
        R --> S[Service Calls]
        S --> T[Repository Operations]
        T --> U[Firebase Operations]
        U --> V[Data Updates]
        V --> W[UI Rebuild]
    end
    
    A --> I
    A --> K
    A --> M
    A --> O
    Q --> R
```

## Technology Stack Architecture

```mermaid
graph TB
    subgraph "Kisan Diary Tech Stack"
        subgraph "Frontend Technologies"
            A[Flutter 3.9.2] --> B[Dart 3.6.0+]
            B --> C[Material Design 3]
            C --> D[Provider State Management]
            D --> E[Sizer Responsive Layout]
            E --> F[Google Fonts Typography]
        end
        
        subgraph "Backend Services"
            G[Firebase Auth] --> H[Cloud Firestore]
            H --> I[Firebase Storage]
            I --> J[Google Sign-In]
            J --> K[Firebase Analytics]
        end
        
        subgraph "Development Tools"
            L[Android Studio] --> M[VS Code]
            M --> N[Firebase CLI]
            N --> O[Flutter Launcher Icons]
            O --> P[Git Version Control]
        end
        
        subgraph "Key Dependencies"
            Q[fl_chart] --> R[shared_preferences]
            R --> S[connectivity_plus]
            S --> T[intl]
            T --> U[image_picker]
            U --> V[cached_network_image]
        end
    end
    
    A --> G
    G --> L
    L --> Q
```

## Data Flow Architecture

```mermaid
sequenceDiagram
    participant U as User
    participant UI as Flutter UI
    participant P as Provider
    participant S as Service
    participant R as Repository
    participant F as Firebase
    
    U->>UI: User Action
    UI->>P: Trigger Provider Method
    P->>S: Call Service Method
    S->>R: Execute Repository Operation
    R->>F: Firebase API Call
    F-->>R: Data Response
    R-->>S: Processed Data
    S-->>P: Business Logic Result
    P-->>UI: State Update
    UI-->>U: UI Refresh
```

## Security Architecture

```mermaid
graph TB
    subgraph "Security Layers"
        A[User Input] --> B[Input Validation]
        B --> C[Authentication Layer]
        C --> D[Authorization Layer]
        D --> E[Data Encryption]
        E --> F[Secure Storage]
        F --> G[API Security]
        G --> H[Firebase Security Rules]
    end
    
    subgraph "Authentication Flow"
        I[Login Screen] --> J[Firebase Auth]
        J --> K[Google OAuth]
        K --> L[Token Generation]
        L --> M[Session Management]
        M --> N[User State]
    end
    
    A --> I
    H --> N
```

## Database Schema Architecture

```mermaid
erDiagram
    USERS {
        string uid PK
        string name
        string email
        string phoneNumber
        string farmLocation
        number costPerLiterCow
        number costPerLiterBuffalo
        timestamp createdAt
        timestamp updatedAt
        number age
        number cattleOwned
    }
    
    EXPENSES {
        string id PK
        string userId FK
        string timestamp
        string dayKey
        string category
        string description
        number totalAmount
        string createdAt
        string updatedAt
    }
    
    INCOME {
        string id PK
        string userId FK
        string dateTime
        string animalType
        string session
        number liters
        number snf
        number fat
        number costPerLiter
        number totalIncome
        string createdAt
        string updatedAt
    }
    
    USERS ||--o{ EXPENSES : has
    USERS ||--o{ INCOME : has
```

## Deployment Architecture

```mermaid
graph TB
    subgraph "Development Environment"
        A[Local Development] --> B[Flutter SDK]
        B --> C[Firebase Emulator]
        C --> D[Git Repository]
    end
    
    subgraph "CI/CD Pipeline"
        E[Code Push] --> F[Automated Testing]
        F --> G[Build Process]
        G --> H[Quality Checks]
        H --> I[Deployment]
    end
    
    subgraph "Production Environment"
        J[Google Play Store] --> K[Android APK]
        L[App Store] --> M[iOS App]
        N[Web Hosting] --> O[Web App]
        P[Firebase Console] --> Q[Production Database]
    end
    
    D --> E
    I --> J
    I --> L
    I --> N
    I --> P
```

## Performance Architecture

```mermaid
graph TB
    subgraph "Performance Optimization"
        A[Lazy Loading] --> B[Image Caching]
        B --> C[State Management]
        C --> D[Memory Management]
        D --> E[Network Optimization]
        E --> F[Offline Support]
    end
    
    subgraph "Firebase Optimization"
        G[Query Optimization] --> H[Indexing Strategy]
        H --> I[Data Pagination]
        I --> J[Real-time Updates]
        J --> K[Offline Caching]
    end
    
    subgraph "UI Performance"
        L[Smooth Animations] --> M[Efficient Rendering]
        M --> N[Responsive Layouts]
        N --> O[Battery Optimization]
    end
    
    A --> G
    G --> L
```

This architecture diagram provides a comprehensive view of the Kisan Diary application's structure, showing how different components interact and how data flows through the system. The modular design ensures scalability, maintainability, and ease of development.
