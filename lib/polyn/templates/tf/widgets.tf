// STREAM DEFINITION

resource "jetstream_stream" "widgets" {
  name = "app_widgets"
  subjects = ["app.widgets.*.*"]
  storage = "file"
  max_age  = 60 * 60 * 24 * 365 // 1 year
}


  // CONSUMERS

// app.widgets.created_notifier 

resource "jetstream_consumer" "app_widgets_created_notifier_app_widgets" {
  stream_id = jetstream_stream.widgets.id
  durable_name = "app_widgets_created_notifier_app_widgets"
  deliver_all = true
  filter_subject = "app.widgets.created.v1"
  sample_freq = 100
}
