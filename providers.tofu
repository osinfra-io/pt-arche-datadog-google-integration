terraform {
  required_providers {

    # Datadog Provider
    # https://search.opentofu.org/provider/datadog/datadog/latest/docs

    datadog = {
      source  = "datadog/datadog"
      version = ">= 3.0"
    }

    # Google Cloud Platform Provider
    # https://search.opentofu.org/provider/hashicorp/google/latest/docs

    google = {
      source  = "hashicorp/google"
      version = ">= 6.0"
    }

    # Random Provider
    # https://search.opentofu.org/provider/hashicorp/random/latest/docs

    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
  }
}
