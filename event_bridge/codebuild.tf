resource "aws_codebuild_project" "nuke-all" {
  name          = "nuke-all-resources"
  description   = "To nuke all resources"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_role.arn

  source {
    type = "NO_SOURCE"
    # buildspec = file("./codebuild.yaml")
    buildspec = templatefile("./codebuild.yaml", 
    {instance_id = aws_instance.test_instance.id})

  }

  environment {
    type         = "LINUX_CONTAINER"
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:2.0"

  }

  artifacts {
    type = "NO_ARTIFACTS"


  }

}
