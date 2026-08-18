# JMeter Performance Testing

[![JMeter Performance Tests](https://github.com/WesleyCouti/jmeter-performance-testing/actions/workflows/jmeter.yml/badge.svg)](https://github.com/WesleyCouti/jmeter-performance-testing/actions/workflows/jmeter.yml)

Performance testing project built with **Apache JMeter 5.6.3**, covering smoke, load and stress testing with configurable workloads, external test data, performance quality gates, HTML reports and continuous integration with GitHub Actions.

This project is part of my **QA Automation portfolio** and demonstrates how I structure performance tests by separating test plans, workload configuration, test data, result validation and CI execution.

---

## Tech Stack

- Apache JMeter 5.6.3
- HTTP Request Samplers
- HTTP Request Defaults
- CSV Data Set Config
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

The project contains three performance profiles with different objectives:

| Profile | Purpose |
|---|---|
| Smoke | Validate availability and basic response behavior |
| Load | Validate behavior under expected concurrent workload |
| Stress | Validate behavior under a higher and sustained workload |

The idea is to keep each test focused on a specific performance objective instead of using the same workload with different numbers.

---

# Smoke Test

The Smoke profile performs a quick validation before running heavier performance tests.

It validates:

- API availability
- HTTP status `200`
- Expected response content
- Response-time SLA
- Performance quality gates

### Default Workload

```text
Virtual users: 1
Ramp-up:       1 second
Loops:         1
```

### Validated Smoke Execution

```text
Total samples:            1
Failed samples:           0
Error rate:               0.00%
Average response time:    653 ms
P95 response time:        653 ms
P99 response time:        653 ms
Approx. throughput:       1.00 req/s
Execution window:         1.00 s
```

### Smoke Quality Gates

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

> The Smoke execution uses only one sample by design. Its purpose is to provide a quick availability and baseline validation before executing larger workloads.

---

# Load Test

The Load profile validates the API under an expected concurrent workload.

### Default Workload

```text
Virtual users: 10
Ramp-up:       10 seconds
Loops:         5
Think time:    250 ms
```

The default configuration produces approximately:

```text
10 users × 5 iterations
        ↓
50 HTTP requests
```

The test uses external CSV data to distribute different post IDs between requests.

### Load Validations

The Load profile validates:

- HTTP status `200`
- Expected response content
- Requested resource ID
- Response-time SLA
- Error rate
- Average response time
- P95 response time
- P99 response time
- Throughput

### Validated Load Execution

```text
Total samples:            50
Failed samples:           0
Error rate:               0.00%
Average response time:    34 ms
P95 response time:        61 ms
P99 response time:        910 ms
Approx. throughput:       5.04 req/s
Execution window:         9.92 s
```

### Load Quality Gates

```text
Error Rate <= 1%
Average    <= 1000 ms
P95        <= 1500 ms
P99        <= 2000 ms
```

Result:

```text
Performance quality gate passed.
```

The execution completed all **50 samples without failures** and remained within all configured performance thresholds.

---

# Stress Test

The Stress profile applies a higher workload to evaluate application behavior under increased traffic.

Unlike the Load profile, the Stress test uses a sustained workload strategy instead of relying only on a fixed number of loops.

This makes it possible to maintain concurrent requests during a configured execution period.

### Stress Strategy

```text
Concurrent Users
       ↓
Ramp-up
       ↓
Continuous Requests
       ↓
Configured Duration
       ↓
Performance Analysis
```

The workload can be adjusted through JMeter properties without changing the `.jmx` file.

### Stress Validations

The Stress profile validates:

- HTTP status `200`
- Expected response content
- Requested resource ID
- Response-time SLA
- Error rate
- Average response time
- P95 response time
- P99 response time
- Throughput

### Validated Stress Execution

```text
Total samples:            800
Failed samples:           0
Error rate:               0.00%
Average response time:    10 ms
P95 response time:        11 ms
P99 response time:        24 ms
Approx. throughput:       27.01 req/s
Execution window:         29.62 s
```

### Stress Quality Gates

```text
Error Rate <= 2%
Average    <= 1500 ms
P95        <= 2500 ms
P99        <= 4000 ms
```

Result:

```text
Performance quality gate passed.
```

The Stress execution processed **800 samples without failures** while remaining below all configured response-time thresholds.

---

# Validated Performance Results

The three performance profiles were successfully executed through the CI pipeline.

| Metric | Smoke | Load | Stress |
|---|---:|---:|---:|
| Total Samples | 1 | 50 | 800 |
| Failed Samples | 0 | 0 | 0 |
| Error Rate | 0.00% | 0.00% | 0.00% |
| Average Response Time | 653 ms | 34 ms | 10 ms |
| P95 | 653 ms | 61 ms | 11 ms |
| P99 | 653 ms | 910 ms | 24 ms |
| Approx. Throughput | 1.00 req/s | 5.04 req/s | 27.01 req/s |
| Execution Window | 1.00 s | 9.92 s | 29.62 s |
| Quality Gate | PASS | PASS | PASS |

> These results represent individual executions against a public demonstration API and should not be interpreted as a benchmark of JSONPlaceholder infrastructure.

The purpose is to demonstrate workload execution, metric collection, percentile analysis and automated performance validation.

---

# Test Architecture

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
         HTTP Status    Response     Response Time
         Assertions     Validation       SLA
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

# Project Structure

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
| `.github/workflows/` | CI execution and artifact generation |

---

# Parameterization

The test plans use JMeter properties so workloads can be changed without editing the `.jmx` files.

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

### Example Load Execution

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

### Example Stress Execution

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

This allows different workload configurations to be executed using the same test plans.

---

# Test Data Management

The Load and Stress profiles use external test data from:

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

The CSV Data Set Config exposes each value through:

```text
${postId}
```

which is then used dynamically:

```text
GET /posts/${postId}
```

The returned resource is validated against the requested ID.

```text
External Test Data
        ↓
    HTTP Request
        ↓
    API Response
        ↓
     Assertion
```

Keeping test data outside the test plan also makes it easier to change the workload without modifying request implementation.

---

# Assertions

The performance plans contain request-level validations so response times are not measured without checking whether the responses themselves are valid.

## HTTP Status

Expected response:

```text
HTTP 200
```

## Response Content

Responses are validated for expected fields such as:

```text
userId
id
title
body
```

Load and Stress requests also validate the returned resource against the `${postId}` used by the request.

## Response-Time SLA

Individual requests are validated using a configurable Duration Assertion.

Default:

```text
response_time_limit_ms=2000
```

Different execution profiles can use different limits when necessary.

---

# Performance Quality Gates

Performance validation continues after JMeter finishes executing.

The script:

```text
scripts/validate-results.sh
```

reads the generated JTL results and calculates:

- Total samples
- Failed samples
- Error rate
- Average response time
- P95 response time
- P99 response time
- Approximate throughput
- Execution window

The results are then compared against configurable thresholds.

Supported variables:

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

If any configured threshold is exceeded:

```text
Performance quality gate failed.
```

and the script returns a non-zero exit code.

If all metrics remain within the limits:

```text
Performance quality gate passed.
```

This allows the CI pipeline to automatically identify performance executions that do not meet the expected criteria.

---

# Quality Gate Strategy

Performance validation is divided into two levels.

## Request Level

```text
HTTP Status
      +
Response Content
      +
Maximum Response Time
```

These validations happen during JMeter execution.

## Execution Level

```text
Error Rate
    +
Average Response Time
    +
P95
    +
P99
```

These metrics are evaluated after execution using the generated JTL file.

Throughput is also calculated and displayed as part of the performance summary.

This avoids treating a performance test as successful only because the API returned valid HTTP responses.

---

# Local Execution

With Apache JMeter available in the system PATH:

## Smoke

```bash
jmeter \
  -n \
  -t plans/smoke-test.jmx \
  -q config/user.properties \
  -l results/smoke.jtl \
  -e \
  -o reports/smoke
```

## Load

```bash
jmeter \
  -n \
  -t plans/load-test.jmx \
  -q config/user.properties \
  -l results/load.jtl \
  -e \
  -o reports/load
```

## Stress

```bash
jmeter \
  -n \
  -t plans/stress-test.jmx \
  -q config/user.properties \
  -l results/stress.jtl \
  -e \
  -o reports/stress
```

Performance tests are executed using JMeter in **non-GUI mode**.

The graphical interface should be used mainly for creating and debugging test plans rather than generating load.

---

# CI/CD Pipeline

The project uses **GitHub Actions** to execute and validate the performance tests.

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

## Automatic Execution

Pushes and pull requests execute the **Smoke profile** automatically.

This provides a lightweight validation of the project without executing heavier workloads on every repository change.

## Manual Execution

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

This allows Load and Stress executions to be triggered when needed.

---

# CI Artifacts

The pipeline generates artifacts that can be used for later analysis.

## Raw JMeter Results

```text
results/results.jtl
```

The JTL file contains the raw execution data used by the quality gate script.

## HTML Dashboard

```text
reports/html/
```

JMeter generates an HTML performance dashboard containing execution statistics and graphs.

Both outputs are uploaded as GitHub Actions artifacts after the test execution.

---

# Application Under Test

## JSONPlaceholder

The project uses **JSONPlaceholder**, a public REST API commonly used for testing and prototyping.

The current performance scenarios target endpoints such as:

```text
GET /posts
GET /posts/{id}
```

JSONPlaceholder is not affiliated with this project.

---

# Responsible Performance Testing

Because this portfolio uses a public demonstration API, the default workloads are intentionally controlled.

The purpose of the repository is to demonstrate:

- Performance test design
- Workload modeling
- Parameterization
- External test data
- Assertions
- Response-time analysis
- Percentiles
- Throughput
- Quality gates
- CI/CD integration

The objective is not to determine the actual capacity limit of JSONPlaceholder.

Higher workloads should only be executed against environments owned by the tester or where explicit authorization for performance testing has been provided.

---

# Technical Decisions

## Why Separate Smoke, Load and Stress Plans?

Each performance test answers a different question.

```text
Smoke
→ Is the application available and responding correctly?

Load
→ How does it behave under an expected workload?

Stress
→ How does it behave when the workload is increased?
```

Keeping separate plans makes the objective of each execution easier to understand and maintain.

## Why CSV Test Data?

External CSV data prevents every virtual user from executing exactly the same request.

It also keeps test data separate from the test implementation.

## Why Parameterization?

Hardcoding workload values inside the test plan would require changing the `.jmx` file whenever a different execution profile was needed.

JMeter properties allow values such as users, ramp-up, duration and think time to be changed directly from the command line or CI pipeline.

## Why Non-GUI Execution?

JMeter's graphical interface is useful for creating and debugging test plans.

Actual performance executions use non-GUI mode to reduce unnecessary test-runner overhead and make the same tests suitable for CI environments.

## Why Percentiles?

Average response time does not show the complete response-time distribution.

P95 and P99 help identify slower requests that could be hidden by a low average.

## Why Quality Gates?

Collecting performance metrics without evaluating them would require manual analysis after every execution.

The quality gate script converts performance expectations into automated PASS/FAIL criteria.

## Why GitHub Actions?

GitHub Actions provides a repeatable environment where the project can install JMeter, execute the selected performance profile, validate the results and publish reports automatically.

---

# Skills Demonstrated

This project demonstrates practical experience with:

`Apache JMeter` • `Performance Testing` • `Load Testing` • `Stress Testing` • `Smoke Testing` • `Workload Modeling` • `Virtual Users` • `Ramp-up` • `Think Time` • `Parameterization` • `CSV Data Set` • `HTTP Assertions` • `Response-Time SLA` • `Error Rate` • `P95` • `P99` • `Throughput` • `JTL Analysis` • `Bash` • `Performance Quality Gates` • `Non-GUI Execution` • `HTML Dashboard` • `GitHub Actions` • `CI/CD`

---

# Roadmap

Possible future improvements:

- [ ] Add minimum throughput quality gate
- [ ] Generate trend comparisons between executions
- [ ] Add performance baseline comparison
- [ ] Support environment-specific workload profiles
- [ ] Add distributed JMeter execution example
- [ ] Integrate performance metrics with an observability platform

---

# Author

**Wesley Coutinho**

QA Engineer | Test Automation

Playwright • Cypress • API Testing • Performance Testing • JavaScript • TypeScript • SQL • CI/CD

LinkedIn: https://www.linkedin.com/in/wesleycoutinhoqa/  
GitHub: https://github.com/WesleyCouti
