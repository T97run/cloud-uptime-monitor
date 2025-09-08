**`docs/setup.md`** (usage notes)
```markdown
# Setup & Operations


- Change the target URLs via Terraform variable `urls`.
- Adjust frequency with `schedule_expression` (e.g., `rate(15 minutes)`).
- Tear down everything: `terraform destroy`.
- Security: Only the reader Lambda is public; S3 bucket blocks public access.
