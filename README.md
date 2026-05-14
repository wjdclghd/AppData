# AppData Module

Clean Architecture + MVVM 환경에서 App 타겟이 SPM 모듈로 의존하는 형태를 전제로 만든 AppData 모듈입니다.
이 모듈은 **Repository 구현체, DataSource, DTO, Mapper, Error 매핑** 역할에 집중하며, Networking · Keychain · Persistence · SearchEngine 같은 Core Infrastructure 의존을 외부에 직접 노출하지 않고 **공개 DataSource 계약 + 내부 구현체**로 역할을 분리합니다.

모듈 내부는 SearchData, SearchAppStoreData, AuthData 세 도메인을 포함하며,
상위 계층(App Target DIContainer)은 각 도메인의 DataSource와 Repository를 조립해 AppDomain UseCase에 주입합니다.

**요약**
- 조립 진입점: App Target `DIContainer` — DataSource → Repository → UseCase 순서로 조립
- 도메인 구성: `SearchData`, `SearchAppStoreData`, `AuthData`
- 공개 계약: DataSource Protocol, Repository 구현체
- 내부 구현: DTOs, Records, Mappers, Errors, Endpoints
- SearchData: 검색 기록(Persistence), 자동완성(SearchEngine), Seed 색인, 초성 검색 지원
- SearchAppStoreData: App Store 검색 목록·상세 원격 조회
- AuthData: 회원가입·로그인·토큰 재발급·로그아웃, Keychain 토큰·Persistence 세션 저장

---

**모듈 구조**
```text
AppData/
├─ Package.swift
├─ Sources/
│  └─ AppData/
│     ├─ SearchData/
│     │  ├─ Errors/
│     │  │  └─ SearchDataError.swift
│     │  ├─ KoreanChosungExtractor.swift
│     │  ├─ Local/
│     │  │  ├─ SearchHistoryDataSource.swift
│     │  │  ├─ SearchHistoryDataSourceProtocol.swift
│     │  │  ├─ SearchSuggestionDataSource.swift
│     │  │  ├─ SearchSuggestionDataSourceProtocol.swift
│     │  │  ├─ SearchSuggestionScope.swift
│     │  │  ├─ SearchSuggestionSeed.swift
│     │  │  ├─ SearchSuggestionSeedDataSource.swift
│     │  │  ├─ SearchSuggestionSeedDataSourceProtocol.swift
│     │  │  └─ SearchSuggestionSeedIndexer.swift
│     │  ├─ Mapper/
│     │  │  ├─ SearchHistoryRecordMapper.swift
│     │  │  ├─ SearchSuggestionMapper.swift
│     │  │  └─ SearchSuggestionSeedDocumentMapper.swift
│     │  └─ Repository/
│     │     ├─ SearchHistoryRepository.swift
│     │     └─ SearchSuggestionRepository.swift
│     ├─ SearchAppStoreData/
│     │  ├─ DTO/
│     │  │  ├─ SearchAppStoreItemDTO.swift
│     │  │  └─ SearchAppStoreResponseDTO.swift
│     │  ├─ Errors/
│     │  │  └─ SearchAppStoreDataError.swift
│     │  ├─ Mapper/
│     │  │  └─ SearchAppStoreDTOMapper.swift
│     │  ├─ Remote/
│     │  │  ├─ SearchAppStoreDataSource.swift
│     │  │  ├─ SearchAppStoreDataSourceProtocol.swift
│     │  │  └─ SearchAppStoreEndpoint.swift
│     │  └─ Repository/
│     │     ├─ SearchAppStoreDetailRepository.swift
│     │     └─ SearchAppStoreListRepository.swift
│     └─ AuthData/
│        ├─ DTOs/
│        │  ├─ AuthRequestDTO.swift
│        │  └─ AuthResponseDTO.swift
│        ├─ Errors/
│        │  ├─ AuthDataError.swift
│        │  └─ AuthDataErrorMapper.swift
│        ├─ Local/
│        │  ├─ AuthSessionLocalDataSource.swift
│        │  ├─ AuthSessionLocalDataSourceProtocol.swift
│        │  ├─ AuthTokenLocalDataSource.swift
│        │  └─ AuthTokenLocalDataSourceProtocol.swift
│        ├─ Mappers/
│        │  └─ AuthDTOMapper.swift
│        ├─ Remote/
│        │  ├─ AuthEndpoint.swift
│        │  ├─ AuthRemoteDataSource.swift
│        │  ├─ AuthRemoteDataSourceProtocol.swift
│        │  └─ AuthRemoteOperation.swift
│        └─ Repositories/
│           └─ AuthRepository.swift
└─ Tests/
   └─ AppDataTests/
      ├─ AuthDataTests/
      │  ├─ AuthDTOMapperTests.swift
      │  ├─ AuthLocalDataSourceTests.swift
      │  ├─ AuthRemoteDataSourceTests.swift
      │  ├─ AuthRepositoryTests.swift
      │  └─ UseCases/
      │     ├─ LogoutSessionUseCaseTests.swift
      │     └─ RestoreSessionUseCaseTests.swift
      ├─ SearchAppStoreDataTests/
      │  ├─ SearchAppStoreDTOMapperTests.swift
      │  ├─ SearchAppStoreDataSourceTests.swift
      │  ├─ SearchAppStoreDetailRepositoryTests.swift
      │  └─ SearchAppStoreListRepositoryTests.swift
      ├─ SearchDataTests/
      │  ├─ KoreanChosungExtractorTests.swift
      │  ├─ SearchHistoryDataSourceTests.swift
      │  ├─ SearchHistoryRepositoryTests.swift
      │  ├─ SearchSuggestionDataSourceTests.swift
      │  ├─ SearchSuggestionRepositoryTests.swift
      │  ├─ SearchSuggestionSeedDataSourceTests.swift
      │  ├─ SearchSuggestionSeedDocumentMapperTests.swift
      │  └─ SearchSuggestionSeedIndexerTests.swift
      └─ TestDoubles/
         ├─ Fixtures/
         │  ├─ AuthEntity+Fixture.swift
         │  ├─ AuthRecord+Fixture.swift
         │  ├─ AuthResponseDTO+Fixture.swift
         │  ├─ SearchAppStoreItemDTO+Fixture.swift
         │  └─ SearchHistoryRecord+Fixture.swift
         ├─ Spies/
         │  ├─ SpyAuthRemoteDataSource.swift
         │  ├─ SpyAuthRepository.swift
         │  ├─ SpyAuthSessionLocalDataSource.swift
         │  ├─ SpyAuthSessionStore.swift
         │  ├─ SpyAuthTokenLocalDataSource.swift
         │  ├─ SpyAuthTokenStore.swift
         │  ├─ SpyNetworkClient.swift
         │  ├─ SpySearchAppStoreDataSource.swift
         │  ├─ SpySearchEngine.swift
         │  ├─ SpySearchHistoryDataSource.swift
         │  ├─ SpySearchHistoryStore.swift
         │  └─ SpySearchSuggestionDataSource.swift
         └─ Stubs/
            └─ StubSeedDataSource.swift
```

---

**빠른 시작**

App Target의 `DIContainer`에서 DataSource → Repository → UseCase 순으로 조립합니다.

```swift
import AppData
import AppDomain
import Networking
import Persistence
import Keychain
import SearchEngine

// SearchAppStore 조립 예시
let networkClient = URLSessionNetworkClient(requestBuilder: NetworkRequestBuilder())
let dataSource = SearchAppStoreDataSource(networkClient: networkClient)
let repository = SearchAppStoreListRepository(dataSource: dataSource)
let useCase = SearchAppStoreListUseCase(repository: repository)

// SearchHistory 조립 예시
let historyDataSource = SearchHistoryDataSource(store: searchHistoryStore)
let historyRepository = SearchHistoryRepository(dataSource: historyDataSource)

// SearchSuggestion 조립 예시 (SearchEngine 연동)
let engine = try SearchEngineContainer.makeDefault().makeSearchEngine()
let seedDataSource = SearchSuggestionSeedDataSource()
let indexer = SearchSuggestionSeedIndexer(seedDataSource: seedDataSource, searchEngine: engine)
try await indexer.indexSeeds()

let suggestionDataSource = SearchSuggestionDataSource(searchEngine: engine)
let suggestionRepository = SearchSuggestionRepository(dataSource: suggestionDataSource)

// Auth 조립 예시
let authRemoteDataSource = AuthRemoteDataSource(
    networkClient: networkClient,
    baseURL: "https://api.example.com"
)
let tokenLocalDataSource = AuthTokenLocalDataSource(tokenStore: keychainTokenStore)
let sessionLocalDataSource = AuthSessionLocalDataSource(sessionStore: persistenceSessionStore)
let authRepository = AuthRepository(
    remoteDataSource: authRemoteDataSource,
    tokenLocalDataSource: tokenLocalDataSource,
    sessionLocalDataSource: sessionLocalDataSource,
    environment: "production"
)
```

---

**핵심 설계 방향**

- **외부/내부 의존 분리**
  AppDomain UseCase와 Feature는 AppDomain Repository Protocol만 바라봅니다.
  Networking DTO, Keychain Record, Persistence Record, SearchEngine 내부 타입은 AppData 내부에서만 사용합니다.

- **Generic Repository + DataSource**
  Repository와 DataSource 구현체는 Protocol을 타입 파라미터로 받아 테스트에서 TestDouble로 교체할 수 있습니다.
  `any` existential 저장 없이 컴파일 타임에 의존성을 검증합니다.

  ```swift
  public struct SearchHistoryRepository<DataSource: SearchHistoryDataSourceProtocol>: SearchHistoryRepositoryProtocol {
      private let dataSource: DataSource
  }

  public struct AuthRepository<
      RemoteDataSource: AuthRemoteDataSourceProtocol,
      TokenLocalDataSource: AuthTokenLocalDataSourceProtocol,
      SessionLocalDataSource: AuthSessionLocalDataSourceProtocol
  >: AuthRepositoryProtocol {
      private let remoteDataSource: RemoteDataSource
      private let tokenLocalDataSource: TokenLocalDataSource
      private let sessionLocalDataSource: SessionLocalDataSource
  }
  ```

- **Error 계층 분리**
  도메인별 `DataError`가 Infrastructure 오류를 받아 `AuthDataErrorMapper`를 통해 AppDomain `DomainError`로 변환합니다.
  Networking, Keychain, Persistence 세부 에러는 AppDomain까지 노출되지 않습니다.

- **Mapper 패턴**
  DTO/Record → Domain Entity 변환은 Mapper 타입이 전담합니다.
  Repository 구현체는 DataSource 호출과 Mapper 호출만 조합하며 변환 로직을 직접 작성하지 않습니다.

- **Seed 색인 분리**
  검색바 자동완성 seed 데이터는 Bundle JSON → `SearchSuggestionSeedDataSource` → `SearchSuggestionSeedIndexer` → SearchEngine 순으로 색인합니다.
  색인과 검색은 서로 독립된 DataSource 타입이 담당합니다.

---

**SearchSuggestionSeedIndexer**

`SearchSuggestionSeedIndexer`는 로컬 seed 데이터를 SearchEngine에 색인하는 조립 타입입니다.

```swift
public struct SearchSuggestionSeedIndexer<
    SeedDataSource: SearchSuggestionSeedDataSourceProtocol,
    Engine: SearchEngineProtocol & Sendable
>: Sendable
```

- `seedDataSource`에서 seed 목록을 가져옵니다.
- `SearchSuggestionSeedDocumentMapper`로 각 seed를 `SearchDocument`로 변환합니다.
- 한글 제목은 `KoreanChosungExtractor`로 초성을 추출해 `keywords`에 추가합니다.
- `searchEngine.index(_:)`로 documents를 일괄 색인합니다.

```swift
let indexer = SearchSuggestionSeedIndexer(
    seedDataSource: seedDataSource,
    searchEngine: engine
)
try await indexer.indexSeeds()
```

---

**AuthRepository**

`AuthRepository`는 Remote, Keychain, Persistence 세 DataSource를 조합해 Auth 정책을 구현합니다.

```swift
public struct AuthRepository<
    RemoteDataSource: AuthRemoteDataSourceProtocol,
    TokenLocalDataSource: AuthTokenLocalDataSourceProtocol,
    SessionLocalDataSource: AuthSessionLocalDataSourceProtocol
>: AuthRepositoryProtocol, Sendable
```

- `signup`: 원격 API 호출 → `SignupUserEntity` 반환 (로컬 저장 없음)
- `login`: 원격 API 호출 → 세션 Keychain + Persistence 저장 → `AuthSessionEntity` 반환
- `refreshAuthToken`: 원격 API 호출 → 토큰 Keychain 교체 → `AuthSessionEntity` 반환
- `requestLogout`: 원격 API 호출만 수행 (로컬 정리 없음, 정책은 `LogoutSessionUseCase` 담당)
- `fetchStoredToken`: Keychain 조회
- `fetchStoredSession`: Persistence 조회
- `clearLocalSession`: Keychain + Persistence 삭제

로컬 정리 정책("토큰 조회 → 서버 로그아웃 시도 → 실패 무시 → 로컬 정리")은 AppDomain `LogoutSessionUseCase`가 조합합니다.

---

**현재 구현 기능**

### 1. SearchData — 검색 기록 (Persistence)

최근 검색어를 Persistence 기반 로컬 저장소에서 관리합니다.

- `SearchHistoryDataSource`: `SearchHistoryStore` (Persistence)를 통해 Record를 조회·저장·삭제
- `SearchHistoryRepository`: Record → `SearchHistoryEntity` 변환, `SearchDomainError` 매핑
- 저장 시각 주입을 위한 `now: () -> Date` 파라미터 지원

관련 내부 구현: `SearchHistoryDataSource`, `SearchHistoryRecordMapper`, `SearchHistoryRepository`

### 2. SearchData — 자동완성 (SearchEngine)

검색바 입력 중인 키워드에 대한 자동완성 제안을 SearchEngine에서 조회합니다.

- `SearchSuggestionDataSource`: `SearchEngineProtocol.suggest(_:)` 위임, 단일 음절 post-filter 적용
- `SearchSuggestionRepository`: `SearchSuggestion` → `SearchSuggestionEntity` 변환

**단일 완성 음절 post-filter:**
완성 음절 1자(U+AC00–U+D7A3) 입력 시 FTS5 MATCH가 keyword 컬럼까지 과다 매칭하는 현상을 제거합니다.
title에 해당 음절이 포함된 결과만 반환합니다. 자모(초성) 입력은 필터링하지 않습니다.

```swift
// "가" 입력 → "가계부", "가사", "히라가나"만 반환 (title 미포함 결과 제거)
// "ㄷ" 입력 → 필터 없이 그대로 반환 (초성 검색)
```

관련 내부 구현: `SearchSuggestionDataSource`, `SearchSuggestionMapper`

### 3. SearchData — Seed 색인 (초성 검색 포함)

Bundle JSON에서 로드한 seed 데이터를 SearchEngine에 색인합니다. 초성 키워드를 추가해 한글 자모 입력 검색을 지원합니다.

- `SearchSuggestionSeedDataSource`: Bundle JSON(`SearchSuggestionSeeds.json`)에서 seed 로드
- `KoreanChosungExtractor`: 한글 음절에서 초성 시퀀스 추출
  - `"음악"` → `"ㅇㅇ"`, `"당근"` → `"ㄷㄱ"`, `"카카오톡"` → `"ㅋㅋㅌ"`
  - 한글 음절이 없으면 빈 문자열 반환
- `SearchSuggestionSeedDocumentMapper`: seed를 `SearchDocument`로 변환, 초성을 keywords에 추가
- `SearchSuggestionSeedIndexer`: DataSource + Mapper + SearchEngine을 조합해 일괄 색인

```swift
// "ㄷ" 입력 → SearchEngine이 keywords LIKE '%ㄷ%' 경로로 "당근", "동영상" 반환
// KoreanChosungExtractor.extract(from: "음력달력") == "ㅇㄹㄷㄹ"
```

관련 내부 구현: `KoreanChosungExtractor`, `SearchSuggestionSeedDocumentMapper`, `SearchSuggestionSeedIndexer`

### 4. SearchAppStoreData — 원격 검색 (Networking)

App Store 검색 목록과 앱 상세 정보를 iTunes Search API에서 조회합니다.

- `SearchAppStoreDataSource`: `NetworkClientProtocol`을 통해 목록·상세 API 요청, DTO 반환
- `SearchAppStoreListRepository`: DTO → `SearchAppStoreListEntity` 변환
- `SearchAppStoreDetailRepository`: DTO → `SearchAppStoreDetailEntity` 변환, 빈 응답 시 `emptyDetailResponse` 오류 처리
- `SearchAppStoreEndpoint`: iTunes Search API URL 조립

관련 내부 구현: `SearchAppStoreDataSource`, `SearchAppStoreDTOMapper`, `SearchAppStoreEndpoint`

### 5. AuthData — 인증 세션 (Networking + Keychain + Persistence)

회원가입, 로그인, 토큰 재발급, 로그아웃 API 호출과 토큰·세션 로컬 저장을 처리합니다.

- `AuthRemoteDataSource`: `NetworkClientProtocol` 기반 API 호출, `AuthDataErrorMapper`로 NetworkError → AuthDataError 변환
- `AuthTokenLocalDataSource`: `AuthTokenStoreProtocol` (Keychain) 래핑
- `AuthSessionLocalDataSource`: `AuthSessionStoreProtocol` (Persistence) 래핑
- `AuthDTOMapper`: DTO·Record → Domain Entity 변환 (날짜 형식 파싱 포함)
- `AuthDataErrorMapper`: NetworkError 서버 code 기반 → `AuthDataError` 매핑, `AuthDataError` → `AuthDomainError` 매핑
- `AuthRemoteOperation`: login, signup, refresh, logout 맥락별 HTTP 오류 fallback 분기

관련 내부 구현: `AuthRemoteDataSource`, `AuthDTOMapper`, `AuthDataErrorMapper`, `AuthEndpoint`, `AuthRemoteOperation`

---

**공개 모델과 계약**

### DataSource Protocols

| 타입 | 설명 |
|---|---|
| `SearchSuggestionDataSourceProtocol` | 자동완성 제안 조회 계약. `fetchDefaultSuggestions`, `fetchSuggestions` |
| `SearchHistoryDataSourceProtocol` | 최근 검색어 로컬 저장소 계약. `fetchRecentHistory`, `saveHistory`, `deleteHistory`, `clearHistory` |
| `SearchSuggestionSeedDataSourceProtocol` | 자동완성 seed 원천 계약. `fetchSeeds` |
| `SearchAppStoreDataSourceProtocol` | App Store 원격 데이터 계약. `fetchListResults`, `fetchDetailResults` |
| `AuthRemoteDataSourceProtocol` | Auth 원격 계약. `signup`, `login`, `refreshAuthToken`, `logout` |
| `AuthTokenLocalDataSourceProtocol` | Keychain 토큰 저장소 계약. `fetchToken`, `saveToken`, `deleteToken`, `deleteAllTokens` |
| `AuthSessionLocalDataSourceProtocol` | Persistence 세션 저장소 계약. `fetchSession`, `saveSession`, `deleteSession`, `deleteAllSessions` |

### Repository 구현체

| 타입 | 구현 Protocol | 설명 |
|---|---|---|
| `SearchHistoryRepository<DataSource>` | `SearchHistoryRepositoryProtocol` | 최근 검색어 로컬 저장 |
| `SearchSuggestionRepository<DataSource>` | `SearchSuggestionRepositoryProtocol` | 자동완성 제안 조회 |
| `SearchAppStoreListRepository<DataSource>` | `SearchAppStoreListRepositoryProtocol` | App Store 검색 목록 |
| `SearchAppStoreDetailRepository<DataSource>` | `SearchAppStoreDetailRepositoryProtocol` | App Store 앱 상세 |
| `AuthRepository<Remote, Token, Session>` | `AuthRepositoryProtocol` | 인증 세션 전체 |

### Errors

| 타입 | 케이스 | 설명 |
|---|---|---|
| `SearchDataError` | `persistenceFailure`, `searchEngineFailure` | SearchData 계층 오류 |
| `SearchAppStoreDataError` | `remoteFailure`, `invalidResponse`, `decodingFailure`, `emptyDetailResponse` | SearchAppStore 계층 오류 |
| `AuthDataError` | `duplicateEmail`, `invalidCredentials`, `invalidRefreshToken`, `invalidAccessToken`, `inactiveUser`, `accessDenied`, `rateLimitExceeded`, `invalidRequest`, `remoteFailure`, `invalidResponse`, `decodingFailure`, `keychainFailure`, `persistenceFailure` | Auth 계층 오류 (13 케이스) |

### 지원 타입

| 타입 | 설명 |
|---|---|
| `KoreanChosungExtractor` | 한글 음절에서 초성 시퀀스 추출 |
| `SearchSuggestionSeedIndexer<SeedDataSource, Engine>` | seed → SearchEngine 색인 조립 타입 |
| `SearchSuggestionScope` | SearchEngine `SearchScope` 정의. `appStoreSearchBarAutocomplete` |
| `SearchSuggestionSeed` | seed 모델. id, title, body, keywords |
| `AuthRemoteOperation` | Auth API 호출 맥락 식별자. login, signup, refresh, logout |

---

**내부 계층 구성**

### DTOs
서버 API 응답 스키마를 표현하는 `Decodable` 전용 타입입니다. Domain Entity와 무관하며, AppData 내부에서만 사용합니다.
- `SearchAppStoreItemDTO`, `SearchAppStoreResponseDTO`
- `AuthRequestDTO`, `AuthResponseDTO` (SignupResponseDTO, AuthSessionResponseDTO, AuthTokenDTO, AuthUserDTO 포함)

### Mappers
DTO·Record → Domain Entity 변환을 담당합니다. 네트워크 호출과 저장소 접근을 포함하지 않습니다.
- `SearchAppStoreDTOMapper`: `SearchAppStoreItemDTO` → List/Detail Entity
- `SearchHistoryRecordMapper`: `SearchHistoryRecord` → `SearchHistoryEntity`
- `SearchSuggestionMapper`: `SearchSuggestion` (SearchEngine) → `SearchSuggestionEntity`
- `SearchSuggestionSeedDocumentMapper`: `SearchSuggestionSeed` → `SearchDocument` (초성 keywords 추가)
- `AuthDTOMapper`: DTO·Record → Domain Entity (날짜 파싱 포함)

### DataSources
단일 데이터 소스(네트워크 또는 로컬 저장소)와의 입출력을 담당합니다. DataSource 간 조합과 캐시 정책은 Repository가 담당합니다.
- Remote: `SearchAppStoreDataSource`, `AuthRemoteDataSource`
- Local: `SearchHistoryDataSource`, `SearchSuggestionDataSource`, `SearchSuggestionSeedDataSource`, `AuthTokenLocalDataSource`, `AuthSessionLocalDataSource`

### Repositories
Remote/Local DataSource 조합, Mapper 호출, Domain Entity 반환, DataError → DomainError 변환을 담당합니다.
- `SearchHistoryRepository`, `SearchSuggestionRepository`
- `SearchAppStoreListRepository`, `SearchAppStoreDetailRepository`
- `AuthRepository`

### Errors
Infrastructure 오류를 Data 계층 또는 Domain 계층 오류로 변환합니다.
- `SearchDataError`, `SearchAppStoreDataError`, `AuthDataError`: Data 계층 오류 타입
- `AuthDataErrorMapper`: NetworkError → AuthDataError, AuthDataError → AuthDomainError 양방향 변환

### Endpoints
Networking 계층에 전달할 `NetworkEndpoint` 조립을 담당합니다.
- `SearchAppStoreEndpoint`: iTunes Search API URL 및 파라미터 조립
- `AuthEndpoint`: Auth API 경로, 메서드, body 조립

---

**의존성**

| 모듈 | 용도 |
|---|---|
| `AppDomain` | Repository Protocol, Domain Entity, DomainError 정의 |
| `Networking` | `NetworkClientProtocol`, `NetworkEndpoint`, `NetworkError`, `HTTPMethod` |
| `Keychain` | `AuthTokenStoreProtocol`, `AuthTokenRecord` |
| `Persistence` | `SearchHistoryStore`, `AuthSessionStoreProtocol`, `AuthSessionRecord`, `SearchHistoryRecord` |
| `SearchEngine` | `SearchEngineProtocol`, `SearchDocument`, `SearchSuggestion`, `SearchSuggestionQuery`, `SearchScope` |

AppData → AppDomain, Core Infrastructure 방향 의존만 허용합니다. Feature 모듈과 App Target은 AppData 구현체를 직접 import하지 않습니다.

---

**테스트**

모듈은 TestDouble 기반 77개 테스트를 포함합니다.

포함된 테스트 범위:
- SearchData: `KoreanChosungExtractorTests`, `SearchHistoryDataSourceTests`, `SearchHistoryRepositoryTests`, `SearchSuggestionDataSourceTests`, `SearchSuggestionRepositoryTests`, `SearchSuggestionSeedDataSourceTests`, `SearchSuggestionSeedDocumentMapperTests`, `SearchSuggestionSeedIndexerTests`
- SearchAppStoreData: `SearchAppStoreDTOMapperTests`, `SearchAppStoreDataSourceTests`, `SearchAppStoreListRepositoryTests`, `SearchAppStoreDetailRepositoryTests`
- AuthData: `AuthDTOMapperTests`, `AuthRemoteDataSourceTests`, `AuthLocalDataSourceTests`, `AuthRepositoryTests`, `LogoutSessionUseCaseTests`, `RestoreSessionUseCaseTests`

테스트 전략:
- 실제 네트워크·저장소 호출 없이 Spy/Stub 기반으로 검증합니다.
- `SpyNetworkClient`, `SpySearchEngine`, `SpyAuthRemoteDataSource` 등 TestDouble이 호출 횟수와 전달 인자를 기록합니다.
- 초성 추출 시나리오(`"음력달력"` → `"ㅇㄹㄷㄹ"`)와 단일 음절 post-filter 시나리오를 단위 테스트로 고정합니다.
- Auth Error 매핑 경로(서버 code → `AuthDataError` → `AuthDomainError`)를 Repository 테스트에서 검증합니다.

---

**권장 사용 전략**
- 상위 계층은 AppDomain의 Repository Protocol과 Domain Entity 중심으로 의존성을 설계합니다.
- DataSource Protocol, DTO, Mapper, DataError 타입은 AppData 내부 경계 안에서만 사용합니다.
- App Target DIContainer에서 DataSource → Repository 순으로 조립하고 UseCase에 주입합니다.
- SearchSuggestion 색인은 앱 시작 시 `SearchSuggestionSeedIndexer.indexSeeds()`를 한 번 호출합니다.
- Auth `environment` 파라미터는 App Target에서 dev/production을 구분해 주입합니다.

---

**권장 확장 방식**
1. 새 도메인 DataSource가 필요하면 `DataSourceProtocol` → 구현체 순서로 추가합니다.
2. 새 DTO는 `Decodable`만 채택하고 Domain Entity와 분리합니다.
3. DTO → Entity 변환은 반드시 Mapper에 추가합니다.
4. 새 Infrastructure 오류는 DataError case를 추가하고 ErrorMapper에 매핑을 추가합니다.
5. 새 Repository 구현체는 Generic DataSource 파라미터 패턴을 따릅니다.
6. 새 Endpoint는 `NetworkEndpoint`를 static factory로 조립하고 DataSource에서만 참조합니다.
7. 신규 기능 추가 시 테스트를 함께 작성하고 `TestDoubles/`에 필요한 Spy를 추가합니다.

---

Created by: JEONG, Chi-hong  
Updated: May 2026
