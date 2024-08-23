mod "local" {
  title = "dashboards"
  require {
    mod "github.com/turbot/steampipe-mod-aws-insights" {
      version = "*"
    }
  }
}