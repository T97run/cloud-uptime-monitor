# Architecture & Rationale


```mermaid
graph TD
EB[EventBridge schedule] --> L1[Lambda: pinger]
L1 -->|Put status.json| S3[(S3 bucket)]
API[HTTP API] --> L2[Lambda: reader]
L2 -->|Get status.json| S3
GH[GitHub Pages (MkDocs)] -->|fetch /status| API
