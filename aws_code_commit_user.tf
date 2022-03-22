#----------------------------------------
# Code Commit + Code Pipeline
#----------------------------------------
// IAMロール作成
resource "aws_iam_role" "codepipeline_role_user" {
  name = "${var.project_name}-${local.user.target}-pipeline-role"
  assume_role_policy = file("./policy/codepipeline_assume_role_policy.json")
}

// ポリシーの作成
resource "aws_iam_role_policy" "codepipeline_policy_user" {
  name = "${var.project_name}-${local.user.target}-pipeline-policy"
  role = aws_iam_role.codepipeline_role_user.id
  policy = file("./policy/codepipeline_policy.json")
}

# Code Commit リポジトリの作成
resource "aws_codecommit_repository" "repository_user" {
  repository_name = "${var.project_name}-${local.user.target}-repository"
  description     = ""
  default_branch  = "master"
}

# Code Pipeline の作成
resource "aws_codepipeline" "codepipeline_user" {
  name     = "${var.project_name}-${local.user.target}-pipeline"
  role_arn = aws_iam_role.codepipeline_role_user.arn

  artifact_store {
    location = "${aws_s3_bucket.site_user.bucket}"
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
        RepositoryName   = aws_codecommit_repository.repository_user.repository_name
        BranchName       = aws_codecommit_repository.repository_user.default_branch
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
        BucketName = aws_s3_bucket.site_user.bucket
        Extract = "true"
      }
    }
  }
  
}