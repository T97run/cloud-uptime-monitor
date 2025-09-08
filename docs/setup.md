# Setup & Operations

Follow these steps to configure, deploy, preview locally, and safely tear down the stack.

---

## ✅ Prerequisites
- AWS account + credentials configured (e.g., `aws configure`)
- Terraform installed (`terraform -version`)
- Python (for local scripts, if needed)
- MkDocs installed (`pip install mkdocs`), and theme if you use one

---

## ⚙️ Configure Targets & Schedule

### 1) Set your URLs
Define the URLs you want to monitor via a Terraform variable (example below).  
If you use a `terraform.tfvars` file:

```hcl
# terraform.tfvars
urls = [
  "https://example.com",
  "https://status.example.com/health"
]
