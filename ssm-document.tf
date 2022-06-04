resource "aws_ssm_document" "poc" {
  name          = "resize_filesystem"
  document_type = "Command"
  # TODO: Remove hardcoded partitions
  content = <<DOC
  {
    "schemaVersion": "1.2",
    "description": "Resize EBS volume.",
    "parameters": {

    },
    "runtimeConfig": {
      "aws:runShellScript": {
        "properties": [
          {
            "id": "0.aws:runShellScript",
            "runCommand": ["sudo growpart /dev/nvme0n1 1", "sudo resize2fs /dev/nvme0n1p1"]
          }
        ]
      }
    }
  }
DOC
}