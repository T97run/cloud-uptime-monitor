# Architecture & Rationale

<div class="mermaid">
graph TD
  EB["EventBridge (schedule)"] --> P["Lambda: pinger"]
  P -->|"Put status.json"| S3["S3 bucket"]
  API["API Gateway (HTTP API v2)"] --> R["Lambda: reader"]
  R -->|"Get status.json"| S3
  GH["MkDocs (GitHub Pages)"] -->|"GET /status"| API
</div>
