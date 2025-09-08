# Setup & Operations

- Change the target URLs via Terraform variable `urls`.
- Adjust frequency with `schedule_expression` (e.g., `rate(15 minutes)`).
- Tear down everything: `terraform destroy`.
- **Security:** Only the reader Lambda is public; S3 bucket blocks public access.

---

## Preview locally

```bash
mkdocs serve  # http://127.0.0.1:8000
