
##
## bundle.uds.hcl
##

uds {
  bundle_api_version = "uds.dev/v1alpha1"
}

metadata {
  name        = "uds-next-demo"
  description = "Two independent tiny workloads for a UDS CLI Next demo"
  version     = "0.1.0"
}

package "alpha" {
  source       = "./packages/alpha/zarf-package-uds-next-alpha-${sys.arch}-0.1.0.tar.zst"
  values_files = ["values/alpha.yaml"]
  signature_verification {
    public_key = file("cosign.pub")
  }
}

package "bravo" {
  source       = "./packages/bravo/zarf-package-uds-next-bravo-${sys.arch}-0.1.0.tar.zst"
  values_files = ["values/bravo.yaml"]
  signature_verification {
    public_key = file("cosign.pub")
  }
}
