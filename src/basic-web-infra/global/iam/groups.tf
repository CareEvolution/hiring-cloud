resource "aws_iam_group" "hiring_candidates" {
  name = "HiringCandidates"
}

data "aws_iam_policy" "ec2fullaccess" {
  name = "AmazonEC2FullAccess"
}

resource "aws_iam_group_policy_attachment" "test-attach" {
  group      = aws_iam_group.hiring_candidates.name
  policy_arn = data.aws_iam_policy.ec2fullaccess.arn
}