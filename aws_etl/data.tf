data "archive_file" "etl_intake_processor_zip" {
  type = "zip"
  source_dir = "./resources/openidl-etl-intake-processor/"
  output_path = "./resources/openidl-etl-intake-processor.zip"
  depends_on = [local_file.config_intake]
}
data "archive_file" "etl_success_processor_zip" {
  type = "zip"
  source_dir = "./resources/openidl-etl-success-processor/"
  output_path = "./resources/openidl-etl-success-processor.zip"
  depends_on = [local_file.config_success]
}