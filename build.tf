provider "google" {
  project = "gosst-scare-sandbox"
  region  = "us-east1"
}

# ##############################################
#              CLOUD BUILD JOB                 #
# ##############################################
# Google Cloud Build job triggered via GitHub
resource "google_cloudbuild_trigger" "scorecard-binauthz-good-test-cloudbuild-trigger" {
  name        = "scorecard-binauthz-good-trigger"
  description = "Build trigger for a test repository that fails scorecard checks"

  # NB: source repo must be connected manually in Cloud Build console
  github {
    owner = "ossf-tests"
    name  = "scorecard-binauthz-test-good"
    push {
      branch = "^main$"
    }
  }

  filename = "cloudbuild.yaml"
}

# ##############################################
#              GITHUB API TOKEN                #
# ##############################################
# Store the GitHub API token for scorecard to use
var "gh_api_token" {
  type = string
}

resource "google_secret_manager_secret" "secret" {
  secret_id = "github-auth-token"
  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "secret-version" {
  secret      = google_secret_manager_secret.secret.id
  secret_data = var.gh_api_token
}

# ##############################################
#                    KMS KEY                   #
# ##############################################
# Create and sign Container Analysis notes
resource "google_kms_key_ring" "keyring" {
  name     = "scorecard-attestor-keyring"
  location = "global"
}

resource "google_kms_crypto_key" "example-asymmetric-sign-key" {
  name     = "scorecard-attestor-key"
  key_ring = google_kms_key_ring.keyring.id
  purpose  = "ASYMMETRIC_SIGN"

  version_template {
    algorithm = "RSA_SIGN_PKCS1_2048_SHA256"
  }
}


# ##############################################
#                 IAM PERMISSIONS              #
# ##############################################
# The following IAM roles must be attached to your GCP CloudBuild role
# Binary Authorization Attestor Viewer
# Cloud Build Service Account
# Cloud KMS CryptoKey Signer/Verifier
# Container Analysis Notes Attacher
# Container Analysis Notes Editor
# Container Analysis Occurrences for Notes Viewer
# Container Analysis Occurrences Viewer
# Secret Manager Secret Accessor
# Storage Object Viewer
variable "service_account_id" {
  type = string
}

variable "member" {
  type = string
}

resource "google_service_account_iam_member" "permissions_for_cloudbuild_0" {
  service_account_id = var.service_account_id
  role               = "roles/binaryauthorization.attestorsViewer"
  member             = var.member
}

resource "google_service_account_iam_member" "permissions_for_cloudbuild_1" {
  service_account_id = var.service_account_id
  role               = "roles/cloudbuild.builds.builder"
  member             = var.member
}

resource "google_service_account_iam_member" "permissions_for_cloudbuild_2" {
  service_account_id = var.service_account_id
  role               = "roles/cloudkms.signerVerifier"
  member             = var.member
}

resource "google_service_account_iam_member" "permissions_for_cloudbuild_3" {
  service_account_id = var.service_account_id
  role               = "roles/containeranalysis.notes.attacher"
  member             = var.member
}

resource "google_service_account_iam_member" "permissions_for_cloudbuild_4" {
  service_account_id = var.service_account_id
  role               = "roles/containeranalysis.notes.editor"
  member             = var.member
}

resource "google_service_account_iam_member" "permissions_for_cloudbuild_5" {
  service_account_id = var.service_account_id
  role               = "roles/containeranalysis.notes.occurrences.viewer"
  member             = var.member
}

resource "google_service_account_iam_member" "permissions_for_cloudbuild_6" {
  service_account_id = var.service_account_id
  role               = "roles/containeranalysis.occurrences.viewer"
  member             = var.member
}

resource "google_service_account_iam_member" "permissions_for_cloudbuild_7" {
  service_account_id = var.service_account_id
  role               = "roles/secretmanager.secretAccessor"
  member             = var.member
}

resource "google_service_account_iam_member" "permissions_for_cloudbuild_8" {
  service_account_id = var.service_account_id
  role               = "roles/storage.objectViewer"
  member             = var.member
}