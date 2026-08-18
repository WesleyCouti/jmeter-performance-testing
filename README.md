# JMeter Performance Testing

[![JMeter Performance Tests](https://github.com/WesleyCouti/jmeter-performance-testing/actions/workflows/jmeter.yml/badge.svg)](https://github.com/WesleyCouti/jmeter-performance-testing/actions/workflows/jmeter.yml)

Performance testing framework built with **Apache JMeter 5.6.3**, focused on smoke, load and stress testing, configurable workloads, performance quality gates, HTML reporting and continuous integration.

This project is part of my **QA Automation portfolio** and demonstrates a structured approach to performance testing by separating workload profiles, test data, execution configuration, result validation and CI/CD.

---

## Tech Stack

- Apache JMeter 5.6.3
- HTTP Request Samplers
- CSV Data Set Config
- HTTP Request Defaults
- Response Assertions
- Duration Assertions
- Parameterization
- External Test Data
- Non-GUI Execution
- JTL Results
- HTML Dashboard Report
- Bash
- GitHub Actions
- CI/CD

---

## Performance Testing Strategy

The project contains three independent performance profiles:

| Profile | Purpose |
|---|---|
| Smoke | Validate availability and baseline behavior |
| Load | Validate behavior under expected concurrent workload |
| Stress | Observe behavior under sustained increased load |

Each profile has a different execution strategy rather than simply increasing the number of requests.

---

## Smoke Test

The Smoke profile provides fast validation before heavier performance tests are executed.

It validates:

- API availability
- HTTP status `200`
- Expected response content
- Response-time SLA
- Performance quality gates

Default workload:

```text
Virtual users: 1
Ramp-up:       1 second
Loops:         1
```

### Latest Validated Smoke Execution

```text
Total samples:            1
Failed samples:           0
Error rate:               0.00%
Average response time:    810 ms
P95 response time:        810 ms
P99 response time:        810 ms
Approx. throughput:       1.00 req/s
Execution window:         1.00 s
```

Quality gates:

```text
Error Rate <= 0%
Average    <= 1000 ms
P95        <= 1500 ms
P99        <= 2000 ms
```

Result:

```text
Performance quality gate passed.
```

> The Smoke execution contains only one sample by design. Its objective is availability and baseline validation rather than statistical performance analysis.

---

## Load Test

The Load profile validates the application under a configurable concurrent workload.

Default profile:

```text
Virtual users:  10
Ramp-up:        10 seconds
Loops:          5
Think time:     250 ms
```

With the default configuration:

```text
10 users × 5 iterations
        ↓
Approximately 50 HTTP requests
```

The workload uses external CSV data to distribute different post IDs across requests.

The Load profile validates:

- HTTP `200`
- Requested resource ID
- Expected JSON response fields
- Per-request response-time SLA
- Error rate
- Average response time
- P95 response time
- P99 response time
- Throughput

---

## Stress Test

The Stress profile is designed differently from the Load profile.

Instead of executing a fixed number of loops, it runs a **sustained workload for a configurable duration**.

Default profile:

```text
Virtual users:  10
Ramp-up:        20 seconds
Duration:       30 seconds
Think time:     250 ms
```

Execution model:

```text
Concurrent Users
       ↓
Ramp-up
       ↓
Continuous Requests
       ↓
Configured Duration
       ↓
Observe degradation
```

The workload can be increased through command-line properties when executed against an environment where performance testing is authorized.

---

## Test Architecture

```text
                   Performance Profiles
                           │
             ┌─────────────┼─────────────┐
             │             │             │
             ▼             ▼             ▼
           Smoke          Load         Stress
             │             │             │
             └─────────────┼─────────────┘
                           │
                           ▼
                     Test Variables
                           │
               ┌───────────┴───────────┐
               ▼                       ▼
         HTTP Defaults             CSV Test Data
               │                       │
               └───────────┬───────────┘
                           ▼
                     HTTP Requests
                           │
              ┌────────────┼────────────┐
              ▼            ▼            ▼
         HTTP Status    Contract     Response Time
         Assertions    Validation       SLA
              │            │            │
              └────────────┼────────────┘
                           ▼
                        JMeter
                           │
                           ▼
                     results.jtl
                           │
              ┌────────────┴────────────┐
              ▼                         ▼
      HTML Dashboard             Quality Gate
                                       │
                     ┌─────────────────┼─────────────────┐
                     ▼                 ▼                 ▼
                Error Rate           P95/P99        Average Time
                                       │
                                       ▼
                                  PASS / FAIL
```

---

## Project Structure

```text
jmeter-performance-testing/
├── .github/
│   └── workflows/
│       └── jmeter.yml
│
├── config/
│   └── user.properties
│
├── data/
│   └── post-ids.csv
│
├── plans/
│   ├── smoke-test.jmx
│   ├── load-test.jmx
│   └── stress-test.jmx
│
├── scripts/
│   └── validate-results.sh
│
├── .gitignore
└── README.md
```

### Responsibilities

| Directory | Responsibility |
|---|---|
| `plans/` | Smoke, Load and Stress JMeter test plans |
| `data/` | External test data used by performance scenarios |
| `config/` | Default JMeter execution properties |
| `scripts/` | Post-execution result analysis and quality gates |
| `.github/workflows/` | Automated execution and artifact generation |

---

## Parameterization

The test plans use JMeter properties so workloads can be changed without editing `.jmx` files.

Supported properties include:

```text
protocol
base_url
threads
users
ramp_up
loops
duration_seconds
think_time_ms
connect_timeout_ms
response_timeout_ms
response_time_limit_ms
csv_file
```

Example Load execution:

```bash
jmeter \
  -n \
  -t plans/load-test.jmx \
  -q config/user.properties \
  -Jusers=20 \
  -Jramp_up=20 \
  -Jloops=8 \
  -Jthink_time_ms=500 \
  -l results/load.jtl \
  -e \
  -o reports/load
```

Example Stress execution:

```bash
jmeter \
  -n \
  -t plans/stress-test.jmx \
  -q config/user.properties \
  -Jusers=20 \
  -Jramp_up=30 \
  -Jduration_seconds=60 \
  -Jthink_time_ms=250 \
  -l results/stress.jtl \
  -e \
  -o reports/stress
```

---

## Test Data Management

The Load and Stress profiles use:

```text
data/post-ids.csv
```

Example:

```text
postId
1
2
3
4
5
6
7
8
9
10
```

The CSV Data Set Config exposes each value as:

```text
${postId}
```

which is used dynamically in requests:

```text
GET /posts/${postId}
```

The response is then validated against the requested resource ID.

This creates a direct relationship between:

```text
External Data
     ↓
HTTP Request
     ↓
API Response
     ↓
Assertion
```

---

## Assertions

The performance plans include request-level validation.

### HTTP Status

Expected:

```text
HTTP 200
```

### Response Content

Responses are checked for expected fields such as:

```text
userId
id
title
body
```

Load and Stress requests also validate that the returned `id` corresponds to the `${postId}` used in the request.

### Response-Time SLA

A configurable Duration Assertion validates individual response times.

Default:

```text
response_time_limit_ms=2000
```

Stress executions can use different limits depending on the selected profile.

---

## Performance Quality Gates

Performance validation continues after JMeter finishes execution.

The script:

```text
scripts/validate-results.sh
```

processes the generated `.jtl` file and calculates:

- Total samples
- Failed samples
- Error rate
- Average response time
- P95 response time
- P99 response time
- Approximate throughput
- Execution window

The script then compares the results against configurable thresholds.

Supported quality gate variables:

```text
MAX_ERROR_RATE
MAX_AVG_RESPONSE_TIME_MS
MAX_P95_RESPONSE_TIME_MS
MAX_P99_RESPONSE_TIME_MS
```

Example:

```bash
MAX_ERROR_RATE=1 \
MAX_AVG_RESPONSE_TIME_MS=1000 \
MAX_P95_RESPONSE_TIME_MS=1500 \
MAX_P99_RESPONSE_TIME_MS=2000 \
./scripts/validate-results.sh results/results.jtl
```

If any threshold is exceeded:

```text
Performance quality gate failed.
```

and the process exits with a non-zero status.

This allows performance regressions to automatically fail the CI pipeline.

---

## Quality Gate Strategy

The validation architecture works at two levels.

### Request Level

```text
HTTP Status
      +
Response Contract
      +
Maximum Response Time
```

### Test Level

```text
Error Rate
    +
Average Response Time
    +
P95
    +
P99
    +
Throughput Analysis
```

This prevents a test from being considered successful only because every HTTP request returned a valid status code.

---

## Local Execution

With Apache JMeter available in the system PATH:

### Smoke

```bash
jmeter \
  -n \
  -t plans/smoke-test.jmx \
  -q config/user.properties \
  -l results/smoke.jtl \
  -e \
  -o reports/smoke
```

### Load

```bash
jmeter \
  -n \
  -t plans/load-test.jmx \
  -q config/user.properties \
  -l results/load.jtl \
  -e \
  -o reports/load
```

### Stress

```bash
jmeter \
  -n \
  -t plans/stress-test.jmx \
  -q config/user.properties \
  -l results/stress.jtl \
  -e \
  -o reports/stress
```

JMeter is executed in **non-GUI mode** for performance runs.

---

## CI/CD Pipeline

The project uses **GitHub Actions** for automated performance validation.

```text
                  Push / Pull Request
                          │
                          ▼
                 Checkout Repository
                          │
                          ▼
                 Install JMeter 5.6.3
                          │
                          ▼
                 Select Test Profile
                          │
               ┌──────────┼──────────┐
               ▼          ▼          ▼
             Smoke       Load      Stress
               │          │          │
               └──────────┼──────────┘
                          ▼
                 Execute JMeter CLI
                          │
                          ▼
                     results.jtl
                          │
               ┌──────────┴──────────┐
               ▼                     ▼
         HTML Dashboard        Quality Gates
               │                     │
               ▼                     ▼
            Artifact              PASS / FAIL
```

### Automatic Execution

Pushes and pull requests execute the **Smoke profile** automatically.

This keeps CI lightweight while still validating that the target and performance framework are operational.

### Manual Execution

The workflow also supports manual execution through:

```text
workflow_dispatch
```

Available profiles:

```text
smoke
load
stress
```

This makes heavier performance profiles explicit rather than running them on every repository change.

---

## CI Artifacts

Every execution can generate:

### Raw Results

```text
results/results.jtl
```

### HTML Dashboard

```text
reports/html/
```

Both are uploaded as GitHub Actions artifacts and retained for later analysis.

---

## Application Under Test

### JSONPlaceholder

JSONPlaceholder is a public REST API used in this project to demonstrate performance testing concepts.

The current workload targets endpoints such as:

```text
GET /posts
GET /posts/{id}
```

The service is not affiliated with this project.

---

## Responsible Performance Testing

The target used by this portfolio is a public demonstration API.

For that reason, default workloads are intentionally conservative.

The purpose of this repository is to demonstrate:

- Test design
- Workload modeling
- Parameterization
- Performance metrics
- Result analysis
- Quality gates
- CI/CD

rather than generate excessive traffic against a third-party service.

Higher workloads should only be executed against environments that are owned by the tester or where explicit authorization for performance testing has been provided.

---

## Technical Decisions

### Why Separate Smoke, Load and Stress Plans?

Each profile has a different objective.

```text
Smoke
→ Is the application ready to test?

Load
→ How does it behave under expected load?

Stress
→ How does behavior change under sustained increased load?
```

Keeping them separate makes workload intent explicit.

### Why CSV Test Data?

External data prevents every virtual user from executing exactly the same request.

It also keeps test data separate from workload implementation.

### Why Non-GUI Execution?

Performance tests are designed to run through the JMeter command line rather than the graphical interface.

This reduces test-runner overhead and makes execution suitable for CI environments.

### Why Percentiles?

Average response time alone can hide slow requests.

P95 and P99 provide visibility into the slower portion of the response-time distribution.

### Why Quality Gates?

Generating a performance report without evaluating it would require manual inspection after every execution.

Automated quality gates allow defined performance expectations to become part of the pipeline result.

### Why GitHub Actions?

Continuous integration provides a repeatable execution environment and allows Smoke validation, performance analysis and report generation without depending on a local machine.

---

## Skills Demonstrated

This project demonstrates practical experience with:

`Apache JMeter` • `Performance Testing` • `Load Testing` • `Stress Testing` • `Smoke Testing` • `Workload Modeling` • `Virtual Users` • `Ramp-up` • `Think Time` • `Parameterization` • `CSV Data Set` • `HTTP Assertions` • `Response-Time SLA` • `Error Rate` • `P95` • `P99` • `Throughput` • `JTL Analysis` • `Bash` • `Performance Quality Gates` • `Non-GUI Execution` • `HTML Dashboard` • `GitHub Actions` • `CI/CD`

---

## Roadmap

Possible future improvements:

- [ ] Execute and document validated Load profile metrics
- [ ] Execute and document validated Stress profile metrics
- [ ] Add minimum throughput quality gate
- [ ] Generate trend comparisons between executions
- [ ] Add performance baseline comparison
- [ ] Support environment-specific workload profiles
- [ ] Add distributed JMeter execution example
- [ ] Integrate performance metrics with an observability platform

---

## Author

**Wesley Coutinho**

QA Engineer | Test Automation

Playwright • Cypress • API Testing • Performance Testing • JavaScript • TypeScript • SQL • CI/CD

LinkedIn: https://www.linkedin.com/in/wesleycoutinhoqa/  
GitHub: https://github.com/WesleyCouti
