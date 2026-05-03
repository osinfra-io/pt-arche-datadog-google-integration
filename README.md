# Datadog - Google Cloud Platform Integration OpenTofu Module

[![OpenTofu Tests](https://img.shields.io/github/actions/workflow/status/osinfra-io/pt-arche-datadog-google-integration/test.yml?style=for-the-badge&logo=opentofu&color=FEDA15&label=OpenTofu%20Tests)](https://github.com/osinfra-io/pt-arche-datadog-google-integration/actions/workflows/test.yml) [![Dependabot](https://img.shields.io/github/actions/workflow/status/osinfra-io/pt-arche-datadog-google-integration/dependabot.yml?style=for-the-badge&logo=github&color=2088FF&label=Dependabot)](https://github.com/osinfra-io/pt-arche-datadog-google-integration/actions/workflows/dependabot.yml) [![Datadog Security Enabled](https://img.shields.io/badge/Datadog%20Security-Enabled-632CA6?style=for-the-badge&logo=datadog)](https://app.datadoghq.com/security/code-security/repositories?repository_id=pt-arche-datadog-google-integration)

## Repository Description

OpenTofu **example** module that configures Datadog's GCP integration using Workload Identity Federation (STS), eliminating the need for service account key rotation. It provisions a Pub/Sub topic and subscription for log export, a Cloud Asset project feed for resource change tracking, and grants the necessary IAM roles for Datadog monitoring and CSPM. Optionally, a BigQuery dataset and GCS bucket are created to support Datadog Cloud Cost Management.

## 🔩 Usage

> [!TIP]
> You can check the [tests/fixtures](tests/fixtures) directory for example configurations. These fixtures set up the system for testing by providing all the necessary initial code, thus creating good examples on which to base your configurations.

Required APIs (managed with the [pt-arche-google-project](https://github.com/osinfra-io/pt-arche-google-project) child module):

- `bigquerydatatransfer.googleapis.com` (If `enable_cloud_cost_management` is `true`)
- `bigquery.googleapis.com` (If `enable_cloud_cost_management` is `true`)
- `cloudasset.googleapis.com`
- `cloudbilling.googleapis.com`
- `cloudresourcemanager.googleapis.com`
- `compute.googleapis.com`
- `iam.googleapis.com`
- `monitoring.googleapis.com`
- `pubsub.googleapis.com`
- `securitycenter.googleapis.com` (If `is_security_command_center_enabled` is `true`)
- `serviceusage.googleapis.com`

## 🛠️ Tools

- [osinfra-pre-commit-hooks](https://github.com/osinfra-io/pt-techne-pre-commit-hooks)
- [pre-commit](https://github.com/pre-commit/pre-commit)

## 📋 Skills and Knowledge

Links to documentation and other resources required to develop and iterate in this repository successfully.

- [bigquery](https://cloud.google.com/bigquery/docs)
- [cloud asset inventory](https://cloud.google.com/asset-inventory/docs)
- [cloud logging](https://cloud.google.com/logging/docs)
- [gcp-cloud-cost-management](https://docs.datadoghq.com/cloud_cost_management/google_cloud)
- [gcp-integration](https://docs.datadoghq.com/integrations/google_cloud_platform)
- [pub/sub](https://cloud.google.com/pubsub/docs)

## 🔍 Tests

All tests are [mocked](https://opentofu.org/docs/cli/commands/test/#the-mock_provider-blocks) allowing us to test the module without creating infrastructure or requiring credentials. The trade-offs are acceptable in favor of speed and simplicity. In an OpenTofu test, a mocked provider or resource will generate fake data for all computed attributes that would normally be provided by the underlying provider APIs.

```none
tofu init
```

```none
tofu test
```

## 📦 Release

To release a new version, simply push a new tag to the repository. The tag should be in the format `vX.Y.Z` where `X`, `Y`, and `Z` are integers.

```none
git tag vX.Y.Z
git push origin vX.Y.Z
```
