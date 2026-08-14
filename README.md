# JMeter Performance Testing

Projeto de portfólio focado em **testes de performance com Apache JMeter**, cobrindo smoke, carga e estresse em uma API pública, com parametrização, assertions, SLA de tempo de resposta, geração de relatório HTML e execução automatizada no GitHub Actions.

## Objetivo

Demonstrar uma abordagem organizada de Performance Testing, separando planos por finalidade e permitindo que os principais parâmetros de carga sejam ajustados sem alterar os arquivos `.jmx`.

A aplicação utilizada nos testes é a API pública **JSONPlaceholder**.

## Stack

- Apache JMeter 5.6.3
- HTTP Request Samplers
- CSV Data Set Config
- Response Assertions
- Duration Assertions
- Parameterization
- Non-GUI Execution
- HTML Dashboard Report
- GitHub Actions

## Cenários

### Smoke
Valida rapidamente:
- disponibilidade da API;
- HTTP 200;
- tempo máximo de resposta.

### Load
Carga padrão configurável:
- 10 usuários virtuais;
- ramp-up de 10 segundos;
- 5 iterações por usuário;
- massa parametrizada via CSV;
- think time;
- validação de status, corpo e SLA.

### Stress
Carga superior ao cenário padrão:
- 30 usuários virtuais;
- ramp-up de 15 segundos;
- 10 iterações por usuário;
- think time reduzido.

Os valores podem ser sobrescritos por propriedades de linha de comando.

## Estrutura

```text
jmeter-performance-testing/
├── .github/
│   └── workflows/
│       └── jmeter.yml
├── config/
│   └── user.properties
├── data/
│   └── post-ids.csv
├── plans/
│   ├── smoke-test.jmx
│   ├── load-test.jmx
│   └── stress-test.jmx
├── scripts/
│   └── validate-results.sh
└── README.md
```

## Parâmetros

Os planos aceitam propriedades como:

```text
users
ramp_up
loops
think_time_ms
base_url
protocol
response_time_limit_ms
```

Exemplo:

```bash
jmeter \
  -n \
  -t plans/load-test.jmx \
  -q config/user.properties \
  -Jusers=20 \
  -Jramp_up=20 \
  -Jloops=8 \
  -l results/load.jtl \
  -e \
  -o reports/load
```

## Critérios de validação

A suíte inclui:

- validação HTTP 200;
- validação de conteúdo da resposta;
- limite de tempo de resposta;
- validação pós-execução para detectar amostras com falha.

O script `validate-results.sh` faz o pipeline falhar quando existem samples malsucedidos.

## Execução local

Com Apache JMeter disponível no PATH:

```bash
jmeter -n \
  -t plans/smoke-test.jmx \
  -q config/user.properties \
  -l results/smoke.jtl \
  -e \
  -o reports/smoke
```

## GitHub Actions

O workflow **JMeter Performance Tests** permite escolher manualmente entre:

- `smoke`
- `load`
- `stress`

O pipeline:

1. baixa o repositório;
2. instala o Apache JMeter;
3. seleciona o plano;
4. executa em modo non-GUI;
5. gera arquivo `.jtl`;
6. valida falhas;
7. gera dashboard HTML;
8. publica relatório e resultados como artifacts.

## Estratégia de performance

Este projeto diferencia:

- **Smoke:** disponibilidade e validação rápida;
- **Load:** comportamento sob carga esperada;
- **Stress:** comportamento acima da carga normal.

Em uma aplicação real, os valores de usuários, ramp-up, duração e SLA deveriam ser definidos com base em métricas de produção, volumetria esperada e requisitos não funcionais.

## Competências demonstradas

`JMeter` `Performance Testing` `Load Testing` `Stress Testing` `Smoke Testing` `Response Time` `Throughput` `Ramp-up` `Parameterization` `CSV Data Set` `Assertions` `Non-GUI` `HTML Report` `GitHub Actions` `CI/CD`

## Observação

Como o alvo é uma API pública de demonstração, as cargas utilizadas neste repositório são intencionalmente moderadas. O objetivo é demonstrar estratégia e estrutura de teste sem gerar tráfego abusivo em um serviço de terceiros.

## Autor

**Wesley Coutinho**  
QA Engineer | Test Automation

LinkedIn: https://www.linkedin.com/in/wesleycoutinhoqa/  
GitHub: https://github.com/WesleyCouti
