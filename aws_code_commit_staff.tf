#----------------------------------------
# Code Commit + Code Pipeline
#----------------------------------------
// IAMロール作成
resource "aws_iam_role" "codepipeline_role_staff" {
  name = "${var.project_name}-${local.staff.target}-pipeline-role"
  assume_role_policy = file("./policy/codepipeline_assume_role_policy.json")
}

// ポリシーの作成
resource "aws_iam_role_policy" "codepipeline_policy_staff" {
  name = "${var.project_name}-${local.staff.target}-pipeline-policy"
  role = aws_iam_role.codepipeline_role_staff.id
  policy = file("./policy/codepipeline_policy.json")
}

# Code Commit リポジトリの作成
resource "aws_codecommit_repository" "repository_staff" {
  repository_name = "${var.project_name}-${local.staff.target}-repository"
  description     = ""
  default_branch  = "master"
}

# Code Pipeline の作成
resource "aws_codepipeline" "codepipeline_staff" {
  name     = "${var.project_name}-${local.staff.target}-pipeline"
  role_arn = aws_iam_role.codepipeline_role_staff.arn

  artifact_store {
    location = "${aws_s3_bucket.site_staff.bucket}"
    type     = "S3"
  }

  // ソースステージ
  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        RepositoryName   = aws_codecommit_repository.repository_staff.repository_name
        BranchName       = aws_codecommit_repository.repository_staff.default_branch
      }
    }
  }

  // デプロイステージ
  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      input_artifacts = ["SourceArtifact"]

      configuration = {
        BucketName = aws_s3_bucket.site_staff.bucket
        Extract = "true"
      }
    }
  }
  
}