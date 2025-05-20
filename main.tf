# ===============================
# Flink Alert Policy
# ===============================

resource "google_monitoring_alert_policy" "flink_log_alert_policy" {
  display_name = "Flink-error"
  combiner     = "OR"
  enabled      = true
  project      = var.project_id

  notification_channels = [
    "projects/${var.project_id}/notificationChannels/11076007616266814838"
  ]

  conditions {
    display_name = "Flink log"

    condition_threshold {
      filter = <<EOT
resource.type = "k8s_container" AND metric.type = "logging.googleapis.com/user/${google_logging_metric.flink_log_alert_metric.name}"
EOT

      comparison      = "COMPARISON_GT"
      threshold_value = 0
      duration        = "0s"

      aggregations {
        alignment_period     = "600s"
        per_series_aligner   = "ALIGN_DELTA"
        cross_series_reducer = "REDUCE_SUM"
      }

      trigger {
        count = 1
      }
    }
  }

  alert_strategy {
    auto_close = "86400s"
  }

  documentation {
    content = <<EOT
{
  "severity": "CRITICAL",
  "text": "Flink job has failed in project ${var.project_id}. Check logs for details.",
  "@type": "ALERT"
}
EOT
    mime_type = "text/markdown"
  }

  user_labels = {}
}
