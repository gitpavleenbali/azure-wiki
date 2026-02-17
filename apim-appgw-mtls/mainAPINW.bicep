param applicationGateways_hub_uni_apim_npd_appgwv2_001_name string = 'hub-uni-apim-npd-appgwv2-001'
param virtualNetworks_hub_uni_inet_vnet_001_externalid string = '/subscriptions/3f63aec6-3eb8-41a5-8343-803ff18e9fb7/resourceGroups/hub-uni-rgp-001/providers/Microsoft.Network/virtualNetworks/hub-uni-inet-vnet-001'
param publicIPAddresses_hub_uni_apim_npd_appgwv2_pip_001_externalid string = '/subscriptions/3f63aec6-3eb8-41a5-8343-803ff18e9fb7/resourceGroups/APINW-iaas-HUB-rgp-001/providers/Microsoft.Network/publicIPAddresses/hub-uni-apim-npd-appgwv2-pip-001'

resource applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: applicationGateways_hub_uni_apim_npd_appgwv2_001_name
  location: 'westeurope'
  tags: {
    bu_id: '1533'
    application_name: 'azure api management (apim)'
    environment: 'prod'
    owner_email: 'ian.beeson@uniper.energy'
    eam_id: '163689'
    lob_parent: 'Corporate IT'
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      family: 'Generation_2'
    }
    gatewayIPConfigurations: [
      {
        name: 'appGatewayIpConfig'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/gatewayIPConfigurations/appGatewayIpConfig'
        properties: {
          subnet: {
            id: '${virtualNetworks_hub_uni_inet_vnet_001_externalid}/subnets/hub-uni-snet-appg-apim-npd-001-v2'
          }
        }
      }
    ]
    sslCertificates: [
      {
        name: 'mgmt-uat-cert'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-uat-cert'
        properties: {}
      }
      {
        name: 'portal-uat-cert'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-uat-cert'
        properties: {}
      }
      {
        name: 'gateway-uat-cert'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-uat-cert'
        properties: {}
      }
      {
        name: 'portal-uat-2022'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-uat-2022'
        properties: {}
      }
      {
        name: 'mgmt-uat-2022'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-uat-2022'
        properties: {}
      }
      {
        name: 'gateway-dev-cert'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-dev-cert'
        properties: {}
      }
      {
        name: 'mgmt-dev-cert'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-dev-cert'
        properties: {}
      }
      {
        name: 'portal-dev-cert'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-dev-cert'
        properties: {}
      }
      {
        name: 'mgmt-uat.apis.uniper.energy_2023_2024'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-uat.apis.uniper.energy_2023_2024'
        properties: {}
      }
      {
        name: 'portal-uat.apis.uniper.energy_2023_2024'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-uat.apis.uniper.energy_2023_2024'
        properties: {}
      }
      {
        name: 'gateway-uat.apis.uniper.energy_2023_2024'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-uat.apis.uniper.energy_2023_2024'
        properties: {}
      }
      {
        name: 'portal-dev.apis.uniper.energy_26jun_2024'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-dev.apis.uniper.energy_26jun_2024'
        properties: {}
      }
      {
        name: 'gateway-dev.apis.uniper.energy_26jun_2024'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-dev.apis.uniper.energy_26jun_2024'
        properties: {}
      }
      {
        name: 'mgmt-dev.apis.uniper.energy_26jun_2024'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-dev.apis.uniper.energy_26jun_2024'
        properties: {}
      }
      {
        name: 'gateway-uat.apis.uniper.energy_25Mar2025'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-uat.apis.uniper.energy_25Mar2025'
        properties: {}
      }
      {
        name: 'portal-uat.apis.uniper.energy_25Mar2025'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-uat.apis.uniper.energy_25Mar2025'
        properties: {}
      }
      {
        name: 'mgmt-uat.apis.uniper.energy_25Mar2025'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-uat.apis.uniper.energy_25Mar2025'
        properties: {}
      }
      {
        name: 'gateway-uat.apis.uniper.energy_25Mar2025-new'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-uat.apis.uniper.energy_25Mar2025-new'
        properties: {}
      }
      {
        name: 'portal-uat.apis.uniper.energy_25Mar2025-new'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-uat.apis.uniper.energy_25Mar2025-new'
        properties: {}
      }
      {
        name: 'mgmt-uat.apis.uniper.energy_25Mar2025-new'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-uat.apis.uniper.energy_25Mar2025-new'
        properties: {}
      }
      {
        name: 'portal-dev.apis.uniper.energy_26Feb2025'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-dev.apis.uniper.energy_26Feb2025'
        properties: {}
      }
      {
        name: 'mgmt-dev.apis.uniper.energy_26Feb2025'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-dev.apis.uniper.energy_26Feb2025'
        properties: {}
      }
      {
        name: 'gateway-dev.apis.uniper.energy_26Feb2025'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-dev.apis.uniper.energy_26Feb2025'
        properties: {}
      }
      {
        name: 'mgmt-dr.apis.uniper.energy_2024_2025'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-dr.apis.uniper.energy_2024_2025'
        properties: {}
      }
      {
        name: 'portal-dr.apis.uniper.energy_2024_2025'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-dr.apis.uniper.energy_2024_2025'
        properties: {}
      }
      {
        name: 'gateway-dr.apis.uniper.energy_2024_2025'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-dr.apis.uniper.energy_2024_2025'
        properties: {}
      }
      {
        name: 'mgmt-dev.apis.uniper.energy_26Feb2026'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-dev.apis.uniper.energy_26Feb2026'
        properties: {}
      }
      {
        name: 'portal-dev.apis.uniper.energy_26Feb2026'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-dev.apis.uniper.energy_26Feb2026'
        properties: {}
      }
      {
        name: 'gateway-dev.apis.uniper.energy_26Feb2026'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-dev.apis.uniper.energy_26Feb2026'
        properties: {}
      }
      {
        name: 'mgmt-uat.apis.uniper.energy_12Mar2026'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-uat.apis.uniper.energy_12Mar2026'
        properties: {}
      }
      {
        name: 'portal-uat.apis.uniper.energy_12Mar2026'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-uat.apis.uniper.energy_12Mar2026'
        properties: {}
      }
      {
        name: 'gateway-uat.apis.uniper.energy_12Mar2026'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-uat.apis.uniper.energy_12Mar2026'
        properties: {}
      }
    ]
    trustedRootCertificates: [
      {
        name: 'uniperapis-npd-root-cert'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert'
        properties: {
          data: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlGdHpDQ0E1K2dBd0lCQWdJQ0JRa3dEUVlKS29aSWh2Y05BUUVGQlFBd1JURUxNQWtHQTFVRUJoTUNRazB4DQpHVEFYQmdOVkJBb1RFRkYxYjFaaFpHbHpJRXhwYldsMFpXUXhHekFaQmdOVkJBTVRFbEYxYjFaaFpHbHpJRkp2DQpiM1FnUTBFZ01qQWVGdzB3TmpFeE1qUXhPREkzTURCYUZ3MHpNVEV4TWpReE9ESXpNek5hTUVVeEN6QUpCZ05WDQpCQVlUQWtKTk1Sa3dGd1lEVlFRS0V4QlJkVzlXWVdScGN5Qk1hVzFwZEdWa01Sc3dHUVlEVlFRREV4SlJkVzlXDQpZV1JwY3lCU2IyOTBJRU5CSURJd2dnSWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUNEd0F3Z2dJS0FvSUNBUUNhDQpHTXBMbEEwQUxhOERLWXJ3RDRISXJrd1poUjBJbjZzcFJJWHpMNEd0TWg2UVJyK2poaVlhSHY1K0hCZzZYSnhnDQpGeW82ZElNek1IMWhWQkhMN2F2ZzV0S2lmdlZyYnhpM0Nnc3QvZWsrN3dyR3N4RHAzTUpHRi9oZC9hVGEvNTVKDQpXcHptTStZa2x2Yy91bHNySEhvMXd0Wm4vcXRtVUl0dEtHQXI3OWRndzhlVHZJMDJrZk4vK05zUkU4U2NkM2JCDQpycmNDYW9GNnFVV0Q0Z1htdVZiQmxEZVBTSEZqSXV3WFpRZVZpa3ZmajhaYUN1V3c0MTllYXhHckRQbUY2MFRwDQorQVJ6OHVuK1hKaU05WE92YTdSK3pkUmNBaXRNT2VHeWxaVXRRb2ZYMWJPUVE3ZHNFL0hlM2ZiRStJay8wWFgxDQprc09SMVlxSTBKRHMzRzNlaWNKbGNaYUxEUVA5bkw5YkZxeVMyK3IrZVh5dDY2LzNGc3ZielNVcjVSLzdtcC9pDQpVY3c2VXd4STVnNjl5YlIyQmxMbUVST0ZjbU1EQk9BRU5pc2dHUUxvZEtjZnRzbFdadkIxSmR4bndRNWhZSWl6DQpQdEdvL0tQYUhiRFJzU05VMzBSMmJlMUIyTUd5SXJaVEhOODFIZHloZHlveDVDMzE1ZVhieU9ELzVZRFhDMk9nDQovek9oRDdvc0ZSWHFsN1BTb3JXKzhveVdIaHFQSFd5a1lUZTVobk16MTVlV25pTjlncVJNZ2VLaDBicG5YNVVIDQpveWNSN2hZUWU3eEZTa3l5Qk5Lcjc5WDlERkhPVUdvSU1mbVIyZ3lQWkZ3RHd6cUxJRDl1aldjOU90YitmVnVJDQp5Vjc3ekdIY2l6TjMwMFF5TlFsaUJKSVdFTmllSjBmN095SGorT3NkV3dJREFRQUJvNEd3TUlHdE1BOEdBMVVkDQpFd0VCL3dRRk1BTUJBZjh3Q3dZRFZSMFBCQVFEQWdFR01CMEdBMVVkRGdRV0JCUWFoR0s4U0V3ekpRVFU3dEQyDQpBOFFaUnRHVWF6QnVCZ05WSFNNRVp6QmxnQlFhaEdLOFNFd3pKUVRVN3REMkE4UVpSdEdVYTZGSnBFY3dSVEVMDQpNQWtHQTFVRUJoTUNRazB4R1RBWEJnTlZCQW9URUZGMWIxWmhaR2x6SUV4cGJXbDBaV1F4R3pBWkJnTlZCQU1UDQpFbEYxYjFaaFpHbHpJRkp2YjNRZ1EwRWdNb0lDQlFrd0RRWUpLb1pJaHZjTkFRRUZCUUFEZ2dJQkFENEtGazJmDQpCbHVvcm5GZEx3VXZaK1lUUllQRU52Ynp3Q1lNRGJWSFpGMzR0SExKUnFVREdDZFZpWGg5ZHVxV05JQVhJTnpuDQpnL2lOL0FlNDJsOU5MbWV5aFAzWlJQeDNVSUhtZkxUSkRRdHlVL2gyQndkQlI1WU0rK0NDSnBOVmpQNGlIMkJsDQpmRi9uSnJQM01wQ1lVTlEzY1ZYMmtpRjQ5NVY1K3ZndEpvZG1WakIzcGpkNE0xSVFXSzQvWVk3eWFySHZHSDVLDQpXV1BLamFKVzFhY3Z2RllmenpuQjR2c0txQlVzZlUxNlk4WnNsMFE4MG0vRFNoY0srSkRTVjZJWlVhVXRsMEhhDQpCMCtwVU5xUWpaUkc0VDd3bFAwUUFEajFPK2hBNGJSdVZob2d6RzlZamUwdVJZL1c2Wk0vNTdFczN6cldJb3pjDQpoTHNpYjlENDVNWTU2UVNJUE1PNjYxVjZiWUNaSlBWc0FmdjRsN0NVVyt2OTBtL3hkMmdOTldRanJMaFZvUVBSDQpUVUlaM1BoMVdWYWorYWhKZWZpdkRya1JvSHkzYXUwMDBMWW1ZamdhaHd6NDZQMHUwNUIvQjVFcUhkWitYSVdEDQptYkE0Q0QvcFh2azFCK1RKWW01WGY2ZFFsZmU2eUp2bWpxSUJ4ZFptdjNsaDh6d2M0Ym1DWEYyZ3crbllTTDBaDQpvaEVVR1c2eWhodG9Qa2czR29pM1haWmVuTWZ2SjJJSTRwRVpYTkx4SWQyNkYwS0NsM0dCVXpHcG4vWjlZcjl5DQo0YU9USGN5S0psb0pPTkRPMXcyQUZyUjRwVHFIVEkyS3BkVkdsL0lzRUxtOFZDTEFBVkJwUTU3MHN1OXQrT3phDQo4ZU94NzkrUmoxUXFDeVhCSmhuRVVoQUZaZFdDRU9yQ01jMHUNCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0NCg=='
        }
      }
      {
        name: 'uniperapis-npd-root-cert-v2'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert-v2'
        properties: {
          data: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tDQpNSUlGZVRDQ0EyR2dBd0lCQWdJVUdsNU1YbUpFN0svcXl3b2xyTWpyT3IvMGpXd3dEUVlKS29aSWh2Y05BUUVMDQpCUUF3VXpFTE1Ba0dBMVVFQmhNQ1FrMHhHVEFYQmdOVkJBb01FRkYxYjFaaFpHbHpJRXhwYldsMFpXUXhLVEFuDQpCZ05WQkFNTUlGRjFiMVpoWkdseklGUnlkWE4wSUVGdVkyaHZjaUJTYjI5MElFTkJJRWN5TUI0WERURTFNRFF3DQpPVEUwTlRnME4xb1hEVFF3TURRd09URTBOVGcwTjFvd1V6RUxNQWtHQTFVRUJoTUNRazB4R1RBWEJnTlZCQW9NDQpFRkYxYjFaaFpHbHpJRXhwYldsMFpXUXhLVEFuQmdOVkJBTU1JRkYxYjFaaFpHbHpJRlJ5ZFhOMElFRnVZMmh2DQpjaUJTYjI5MElFTkJJRWN5TUlJQ0lqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FnOEFNSUlDQ2dLQ0FnRUFyM0lRDQpXZzAyQ0wxQ3NxaU1TVVU0QjBRRnRUWG1GMWZNdDlwRzFQc1FKWTdjdWowTTNyVUtzUG9QVlVvWG5OamJ6RFdBDQpUbmhhUk1lZmFkUkRvdWhCYURyQmlIRzdQUzZiZmxYdE9tR3dDVTVrSGNwKzU4dVo1Ykp1RE5Wek1CVlp3a21mDQpySWFSSy9xUGFHeHhkZmZIMjdqY0poZUhLZDFIWFNYOGdQZnI2STE5Z2l5LzZiZkpGYnUrNXE3VmxjaWh5dThCDQpIYU12Zmh5TC9qbXBpajJVbkRYT011bVRWeXkxS2lsanhQNDdKOWdjV3JJVGlIZWNVbDdkU3NCejg0UEJXakd3DQpxUldFS1UvT1lSTFhaWUduQjRNcGxjTHJOb2dzQTE3Ujd4WUV6WnJoTkZaZWY3RmJBSGtVSjZsWmFkejZZRnQ4DQpYU09sRmJ4MkMxdisrenloNlIyVWNIcjNvbWxiSVFPN1RtRHZwR0EycVBRbkFGWUY3enlQRFpKTWpmeHBmeG5RDQpsRVNETTMzcWNEbXE4dG85bzc4YzR3bGpLbjJ0TmxsTzVXZmZUVVpzeTVjbWNrSGVSRWIrSHlCdXNFTUtjQmdWDQpPaHl6bWd5emY1OGlDRnc1S3p3L0RnNzM2M2ZRTWFYMVM5dzdtcGEzMGRiN3A1THFrRENEV2VjWHZvb0dxc2g3DQpNUThhL2tNaW1VUnNxODNHUkI0YWZ0UFJwV0R2a2M2TlNQeUtyWS9ZWUFwMnowUnN1MzR5THNleGt2bEQwSHJ5DQpIUHliWkNXQnlCNVVNS01takVqMHo1b2hOZHVPdkxhdm1ZTzNsaDBiV3BXN2V4UUpjWkF6UE9idk10cXgyV0pmDQpMbmtEZXVucGdmYzZsR3VmTWFVUkRCOXc0VFk4TDd0VEtBcm81d2NDQXdFQUFhTkZNRU13SFFZRFZSME9CQllFDQpGT0tCZlBPR2ZmYkRRR01sNEFpeEhjNVE4THIvTUJJR0ExVWRFd0VCL3dRSU1BWUJBZjhDQVFJd0RnWURWUjBQDQpBUUgvQkFRREFnRUdNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUNBUUNYdGlyL1BXakVoRkpFcUJGTUp6ZktocG5iDQpqTlpBclJTQnJwd1RpSHYvd2NZSDg2UHMrMTU1clloc2tlQTYzTWN1Ly9UemR0U1NSY0R3d0lCU2pVTHFhTFZ2DQpSV2RscnQ3YVJJUmdza2ZrTWs4ODNnekx6YW44U3U0a1hCUEtUSDdwSitNSjd5dGhhTC91NUJrcXA1K2NpbG1yDQpGd2NnZ1NRanl3OFhDMzAyODhHSGRMNVNjSWRRM3NrU05nRmdTUDJnTC9iZEpnWWFqUHdDdEtYK0lmWC9DTUFyDQpUOHZ5Kzl1WjZkSGZ1ajNLTitFYkg4bkdRMUtPMEJsRXpFZDdMaVJiMzVQZDJ0dVhMSWVQZCtXOXRUSGhUYnEvDQpYeXBjM3U4T1h5S2tpOWpGWmg3c2E5QXZzOEp3cW0yY3R0ZGJpYzMyL0F1UFZYSW1iMk5NcmUxMWtLeG1JMzl6DQo2MExacFJkUjRiQmZRY2JnNk9UcU1tRCtyU0hFSkdkeld0dmY1OUcxY0JreEgyVVhlaEppYWVUdkRISHdDVDFQDQpLeFNOQ0dtZ1JxWXFDaUtQbFhXUFZUS1VtVm5ZN2Z2Y003YWxaSk11R0V1aWlUOGN1cStQWWtlNDZWcCtEZ0xMDQpMbDJYSmNXMThLVXEzNEZEcWlqTE8xNERzQ0tjRUJ3TWlHVWs4MGFtNlZ5YjhRbmdSUU14NUdwQnlqRHlqU1c2DQp0NFFNS0hHMFEzdkxLak0xdld3bFo0amJSdkxTMmZGMzY3Mkw1b0V2NXU4blo3SXdER3ZpN3BPSnRCNEZRci8zDQp5V0tSWG5tdnhmMFFFZU9HUEpGR2FxMVpUQXdKT0c4blhXRVBxQy9iN2hGZGE4QnV2N3lJMFRKbWVJT1orQjBPDQo4WFg0MlVTNkp3NW96WC93SkE9PQ0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ0K'
        }
      }
      {
        name: 'uniperapis-npd-root-cert-new'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert-new'
        properties: {
          data: 'LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURqakNDQW5hZ0F3SUJBZ0lRQXpyeDVxY1JxYUM3S0dTeEhRbjY1VEFOQmdrcWhraUc5dzBCQVFzRkFEQmgKTVFzd0NRWURWUVFHRXdKVlV6RVZNQk1HQTFVRUNoTU1SR2xuYVVObGNuUWdTVzVqTVJrd0Z3WURWUVFMRXhCMwpkM2N1WkdsbmFXTmxjblF1WTI5dE1TQXdIZ1lEVlFRREV4ZEVhV2RwUTJWeWRDQkhiRzlpWVd3Z1VtOXZkQ0JICk1qQWVGdzB4TXpBNE1ERXhNakF3TURCYUZ3MHpPREF4TVRVeE1qQXdNREJhTUdFeEN6QUpCZ05WQkFZVEFsVlQKTVJVd0V3WURWUVFLRXd4RWFXZHBRMlZ5ZENCSmJtTXhHVEFYQmdOVkJBc1RFSGQzZHk1a2FXZHBZMlZ5ZEM1agpiMjB4SURBZUJnTlZCQU1URjBScFoybERaWEowSUVkc2IySmhiQ0JTYjI5MElFY3lNSUlCSWpBTkJna3Foa2lHCjl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUF1emZOTk54N2E4bXlhSkN0U25YL1Jyb2hDZ2lOOVJsVXlmdUkKMi9PdThqcUprVHg2NXFzR0dtdlByQzNvWGdra1JMcGltbjdXbzZoKzRGUjFJQVdzVUxlY1l4cHNNTnphSHhteAoxeDdlL2RmZ3k1U0RONjdzSDBOTzNYc3MwcjB1cFMva3FiaXRPdFNacExZbDZadHJBR0NTWVA5UElVa1k5MmVRCnEyRUduSS95dXVtMDZaSXlhN1h6VitoZEc4Mk1IYXVWQkpWSjh6VXRsdU5KYmQxMzQvdEpTN1NzVlFlcGo1V3oKdENPN1RHMUY4UGFwc3BVd3RQMU1WWXduU2xjVWZJS2R6WE9TMHhaS0JneU1VTkdQSGdtK0Y2SG1JY3I5ZytVUQp2SU9sQ3NSbktQWnpGQlE5Um5iRGh4U0pJVFJOcnc5RkRLWkpvYnE3bk1XeE00TXBoUUlEQVFBQm8wSXdRREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUE0R0ExVWREd0VCL3dRRUF3SUJoakFkQmdOVkhRNEVGZ1FVVGlKVUlCaVYKNXVOdTVnLzYrcmtTN1FZWGp6a3dEUVlKS29aSWh2Y05BUUVMQlFBRGdnRUJBR0JuS0pSdkRraGo2ekhkNm1jWQoxWWw5UE1XTFNuL3B2dHNyRjkrd1gzTjNLaklUT1lGblFvUWo4a1ZuTmV5SXYvaVBzR0VNTktTdUlFeUV4dHY0Ck5lRjIyZCttUXJ2SFJBaUdmelowSkZyYWJBMFVXVFc5OGtuZHRoL0pzdzFIS2oyWkw3dGN1N1hVSU9HWlgxTkcKRmR0b20vRHpNTlUrTWVLTmhKN2ppdHJhbGo0MUU2VmY4UGx3VUhCSFFSRlhHVTdBajY0R3hKVVRGeThiSlo5MQo4ckdPbWFGdkU3RkJjZjZJS3NoUEVDQlYxL01VUmVYZ1JQVHFoNVV5a3c3K1UwYjZMSjMvaXlLNVM5a0pSYVRlCnBMaWFXTjBiZlZLZmpsbERpSUdrbmliVmI2M2REY1kzZmUwRGtodmxkMTkyN2p5TnhGMVdXNkxaWm02ek5UZmwKTXJZPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg=='
        }
      }
    ]
    trustedClientCertificates: []
    sslProfiles: []
    frontendIPConfigurations: [
      {
        name: 'appGwPublicFrontendIp'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: publicIPAddresses_hub_uni_apim_npd_appgwv2_pip_001_externalid
          }
        }
      }
    ]
    frontendPorts: [
      {
        name: 'port_80'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendPorts/port_80'
        properties: {
          port: 80
        }
      }
      {
        name: 'port_443'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendPorts/port_443'
        properties: {
          port: 443
        }
      }
    ]
    backendAddressPools: [
      {
        name: 'appGatewayBackendPool'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/appGatewayBackendPool'
        properties: {
          backendAddresses: []
        }
      }
      {
        name: 'uniperapis-dev-gateway-bp-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
        properties: {
          backendAddresses: [
            {
              fqdn: 'gateway-dev.apis.uniper.energy'
            }
          ]
        }
      }
      {
        name: 'uniperapis-dev-portal-bp-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-portal-bp-001'
        properties: {
          backendAddresses: [
            {
              fqdn: 'portal-dev.apis.uniper.energy'
            }
          ]
        }
      }
      {
        name: 'uniperapis-dev-mgmt-bp-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-mgmt-bp-001'
        properties: {
          backendAddresses: [
            {
              fqdn: 'mgmt-dev.apis.uniper.energy'
            }
          ]
        }
      }
      {
        name: 'uniperapis-uat-gateway-bp-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
        properties: {
          backendAddresses: [
            {
              fqdn: 'gateway-uat.apis.uniper.energy'
            }
          ]
        }
      }
      {
        name: 'uniperapis-uat-portal-bp-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-portal-bp-001'
        properties: {
          backendAddresses: [
            {
              fqdn: 'portal-uat.apis.uniper.energy'
            }
          ]
        }
      }
      {
        name: 'uniperapis-uat-mgmt-bp-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-mgmt-bp-001'
        properties: {
          backendAddresses: [
            {
              fqdn: 'mgmt-uat.apis.uniper.energy'
            }
          ]
        }
      }
    ]
    loadDistributionPolicies: []
    backendHttpSettingsCollection: [
      {
        name: 'test-http'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/test-http'
        properties: {
          port: 80
          protocol: 'Http'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: false
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 20
        }
      }
      {
        name: 'uniperapis-uat-portal-HttpSettings-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-portal-HttpSettings-001'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 60
          probe: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-uat-portal-probe-01'
          }
          trustedRootCertificates: [
            {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert'
            }
            {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert-new'
            }
          ]
        }
      }
      {
        name: 'uniperapis-uat-mgmt-HttpSettings-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-mgmt-HttpSettings-001'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 60
          probe: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-uat-mgmt-probe-01'
          }
          trustedRootCertificates: [
            {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert'
            }
            {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert-new'
            }
          ]
        }
      }
      {
        name: 'uniperapis-uat-gateway-HttpSettings-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 300
          probe: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-uat-gateway-probe-01'
          }
          trustedRootCertificates: [
            {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert'
            }
            {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert-new'
            }
          ]
        }
      }
      {
        name: 'uniperapis-dev-portal-HttpSettings-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-portal-HttpSettings-001'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 60
          probe: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-dev-portal-probe-01'
          }
          trustedRootCertificates: [
            {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert-new'
            }
          ]
        }
      }
      {
        name: 'uniperapis-dev-mgmt-HttpSettings-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-mgmt-HttpSettings-001'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 60
          probe: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-dev-mgmt-probe-01'
          }
          trustedRootCertificates: [
            {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert-new'
            }
          ]
        }
      }
      {
        name: 'uniperapis-dev-gateway-HttpSettings-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
        properties: {
          port: 443
          protocol: 'Https'
          cookieBasedAffinity: 'Disabled'
          pickHostNameFromBackendAddress: true
          affinityCookieName: 'ApplicationGatewayAffinity'
          requestTimeout: 300
          probe: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-dev-gateway-probe-01'
          }
          trustedRootCertificates: [
            {
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/trustedRootCertificates/uniperapis-npd-root-cert-new'
            }
          ]
        }
      }
    ]
    backendSettingsCollection: []
    httpListeners: [
      {
        name: 'test-listener'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/test-listener'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendPorts/port_80'
          }
          protocol: 'Http'
          hostNames: []
          requireServerNameIndication: false
        }
      }
      {
        name: 'uniperapis-dev-mgmt-listener-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-dev-mgmt-listener-001'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-dev.apis.uniper.energy_26Feb2026'
          }
          hostName: 'mgmt-dev.apis.uniper.energy'
          hostNames: []
          requireServerNameIndication: true
          customErrorConfigurations: []
        }
      }
      {
        name: 'uniperapis-dev-portal-listener-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-dev-portal-listener-001'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-dev.apis.uniper.energy_26Feb2026'
          }
          hostName: 'portal-dev.apis.uniper.energy'
          hostNames: []
          requireServerNameIndication: true
          customErrorConfigurations: []
        }
      }
      {
        name: 'uniperapis-dev-gateway-listener-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-dev-gateway-listener-001'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-dev.apis.uniper.energy_26Feb2026'
          }
          hostName: 'gateway-dev.apis.uniper.energy'
          hostNames: []
          requireServerNameIndication: true
          customErrorConfigurations: []
        }
      }
      {
        name: 'uniperapis-uat-mgmt-listener-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-uat-mgmt-listener-001'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/mgmt-uat.apis.uniper.energy_12Mar2026'
          }
          hostName: 'mgmt-uat.apis.uniper.energy'
          hostNames: []
          requireServerNameIndication: true
          customErrorConfigurations: []
        }
      }
      {
        name: 'uniperapis-uat-portal-listener-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-uat-portal-listener-001'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/portal-uat.apis.uniper.energy_12Mar2026'
          }
          hostName: 'portal-uat.apis.uniper.energy'
          hostNames: []
          requireServerNameIndication: true
          customErrorConfigurations: []
        }
      }
      {
        name: 'uniperapis-uat-gateway-listener-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-uat-gateway-listener-001'
        properties: {
          frontendIPConfiguration: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendIPConfigurations/appGwPublicFrontendIp'
          }
          frontendPort: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/frontendPorts/port_443'
          }
          protocol: 'Https'
          sslCertificate: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/sslCertificates/gateway-uat.apis.uniper.energy_12Mar2026'
          }
          hostName: 'gateway-uat.apis.uniper.energy'
          hostNames: []
          requireServerNameIndication: true
          customErrorConfigurations: []
        }
      }
    ]
    listeners: []
    urlPathMaps: [
      {
        name: 'uniperapis-uat-gateway-pathbased-rule-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001'
        properties: {
          defaultBackendAddressPool: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/appGatewayBackendPool'
          }
          defaultBackendHttpSettings: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
          }
          pathRules: [
            {
              name: 'EAM-UAT'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/EAM-UAT'
              properties: {
                paths: [
                  '/api/eam/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'ilp'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/ilp'
              properties: {
                paths: [
                  '/api/ilp/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'DataservicesESBVPC'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/DataservicesESBVPC'
              properties: {
                paths: [
                  '/api/dataservicesesbvpc/pricerequest/uat/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Fuse-sharp-nip-uat'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/Fuse-sharp-nip-uat'
              properties: {
                paths: [
                  '/api/uat/nordic/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'favicon.ico'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/favicon.ico'
              properties: {
                paths: [
                  '/favicon.ico'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Endur-EIS'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/Endur-EIS'
              properties: {
                paths: [
                  '/api/endur-eis-ca-ext/*'
                  '/api/uat/imos/*'
                  '/api/endur-eis-ca-dev/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'servicenow'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/servicenow'
              properties: {
                paths: [
                  '/api/servicenow-tableapi/*'
                  '/api/servicenow-attachment/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'tempo2-atom'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/tempo2-atom'
              properties: {
                paths: [
                  '/api/atom-tempo2/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'capman'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/capman'
              properties: {
                paths: [
                  '/api/capman/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'azure-cognitiveservices'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/azure-cognitiveservices'
              properties: {
                paths: [
                  '/api/azure-cognitiveservices-translator/*'
                  '/api/azure-cognitiveservices-textanalytics/*'
                  '/api/azure-cognitiveservices-formrecognizer/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Rundeck-REM'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/Rundeck-REM'
              properties: {
                paths: [
                  '/api/rundeck-rem/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'MDAP-EBP'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/MDAP-EBP'
              properties: {
                paths: [
                  '/api/mdap-ebp/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'deltaxe-odata'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/deltaxe-odata'
              properties: {
                paths: [
                  '/api/dtxe-odata/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'sap-lmra'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/sap-lmra'
              properties: {
                paths: [
                  '/api/sap-lmra/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Fuse-Common-api'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/Fuse-Common-api'
              properties: {
                paths: [
                  '/api/commonapi*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'snowflake'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/snowflake'
              properties: {
                paths: [
                  '/api/snowflake/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'STP-Reporting'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/STP-Reporting'
              properties: {
                paths: [
                  '/api/sales-trading-portal-reporting*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'crmues-emails-read'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/crmues-emails-read'
              properties: {
                paths: [
                  '/api/crmues*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'coode-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/coode-related-apis'
              properties: {
                paths: [
                  '/api/coode*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'laser3-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/laser3-related-apis'
              properties: {
                paths: [
                  '/api/laser3/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Mira-Apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/Mira-Apis'
              properties: {
                paths: [
                  '/api/mira*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'apple-dev-APIs'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/apple-dev-APIs'
              properties: {
                paths: [
                  '/api/appstoreconnect/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Holiday'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/Holiday'
              properties: {
                paths: [
                  '/api/holidaycalendar/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Infobasis-Apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/Infobasis-Apis'
              properties: {
                paths: [
                  '/api/infobasis/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Digicision-Related-Apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/Digicision-Related-Apis'
              properties: {
                paths: [
                  '/api/digicision*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'xkey-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/xkey-related-apis'
              properties: {
                paths: [
                  '/api/xkey/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'eai-usip-v10'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/eai-usip-v10'
              properties: {
                paths: [
                  '/api/eai-usip/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'cpi-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/cpi-related-apis'
              properties: {
                paths: [
                  '/api/cpi/*'
                  '/api/sap_sp_legal/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'intesi-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/intesi-related-apis'
              properties: {
                paths: [
                  '/api/intesi/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'hive-related-api'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/hive-related-api'
              properties: {
                paths: [
                  '/api/thehive/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Datahub-int'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/Datahub-int'
              properties: {
                paths: [
                  '/datahub-int/*'
                  '/datahubdr/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'pkfg'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/pkfg'
              properties: {
                paths: [
                  '/api/pkfg-productconfiguration/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'sap-seeburger'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/sap-seeburger'
              properties: {
                paths: [
                  '/api/sapisu-forecast/*'
                  '/api/sapisu-x63-idoc/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Rest_proxy'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/Rest_proxy'
              properties: {
                paths: [
                  '/api/rest-proxy/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'enmacc'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/enmacc'
              properties: {
                paths: [
                  '/api/sales-trading-portal-enmacc-demand/*'
                  '/api/enmacc-connect/*'
                  '/api/enmacc-service-read/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'EAI-USIP-MAR'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/EAI-USIP-MAR'
              properties: {
                paths: [
                  '/api/usip-utilities/*'
                  '/api/usip-confluent-utilities/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Robotron-NeonICC'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/Robotron-NeonICC'
              properties: {
                paths: [
                  '/api/redispatch/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'seeburgeras4-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/seeburgeras4-related-apis'
              properties: {
                paths: [
                  '/api/seeburgeras4-neon/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'ConnTest'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/ConnTest'
              properties: {
                paths: [
                  '/test/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'myidentity'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/myidentity'
              properties: {
                paths: [
                  '/api/myidentity-b2cservice/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'mdm-related-api'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/mdm-related-api'
              properties: {
                paths: [
                  '/api/mdmwebservice/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'ds-api'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/ds-api'
              properties: {
                paths: [
                  '/api/ds-api/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'pegasus'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/pegasus'
              properties: {
                paths: [
                  '/api/pegasus-*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'UMS-Related-APIs'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/UMS-Related-APIs'
              properties: {
                paths: [
                  '/api/ums-*'
                  '/api/ums/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'mia-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/mia-related-apis'
              properties: {
                paths: [
                  '/api/mia-*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'azure-maps'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/azure-maps'
              properties: {
                paths: [
                  '/api/maps/search/*'
                  '/api/maps/timezone/*'
                  '/api/maps/weather/*'
                  '/api/maps/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'API-ex-aiworks'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/API-ex-aiworks'
              properties: {
                paths: [
                  '/api/ex/*'
                  '/ex-aiworks*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'salerportal-related-APis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/salerportal-related-APis'
              properties: {
                paths: [
                  '/api/salesportal-*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'UES_Api'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001/pathRules/UES_Api'
              properties: {
                paths: [
                  '/api/ues-*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-gateway-HttpSettings-001'
                }
              }
            }
          ]
        }
      }
      {
        name: 'uniperapis-dev-gateway-pathbased-rule-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001'
        properties: {
          defaultBackendAddressPool: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/appGatewayBackendPool'
          }
          defaultBackendHttpSettings: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
          }
          pathRules: [
            {
              name: 'favicon.ico'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/favicon.ico'
              properties: {
                paths: [
                  '/favicon.ico'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'azure-cognitiveservices'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/azure-cognitiveservices'
              properties: {
                paths: [
                  '/api/azure-cognitiveservices-translator/*'
                  '/api/azure-cognitiveservices-textanalytics/*'
                  '/api/azure-cognitiveservices-formrecognizer/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'atom-tempo2'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/atom-tempo2'
              properties: {
                paths: [
                  '/api/atom-tempo2/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'tableau-management-portal'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/tableau-management-portal'
              properties: {
                paths: [
                  '/api/Tableau/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Infobasis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/Infobasis'
              properties: {
                paths: [
                  '/api/infobasis/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'rundeck-rem'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/rundeck-rem'
              properties: {
                paths: [
                  '/api/rundeck-rem/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'capman'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/capman'
              properties: {
                paths: [
                  '/api/capman/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'veslink-eis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/veslink-eis'
              properties: {
                paths: [
                  '/api/veslink-eis/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'MDAP-EBP'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/MDAP-EBP'
              properties: {
                paths: [
                  '/api/mdap-ebp/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'deltaxe'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/deltaxe'
              properties: {
                paths: [
                  '/api/dtxe-odata/*'
                  '/api/dtxe-tso/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Fuse-common-api'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/Fuse-common-api'
              properties: {
                paths: [
                  '/api/commonapi/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Snowflake'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/Snowflake'
              properties: {
                paths: [
                  '/api/snowflake/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'connection-test'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/connection-test'
              properties: {
                paths: [
                  '/test*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'stp-reporting-v10'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/stp-reporting-v10'
              properties: {
                paths: [
                  '/api/sales-trading-portal-reporting*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'coode-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/coode-related-apis'
              properties: {
                paths: [
                  '/api/coode*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Uniper-Digital'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/Uniper-Digital'
              properties: {
                paths: [
                  '/api/uniper-digital-backend-response/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'laser3'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/laser3'
              properties: {
                paths: [
                  '/api/laser3/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'crmues-realted-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/crmues-realted-apis'
              properties: {
                paths: [
                  '/api/crmues*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'api-mira'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/api-mira'
              properties: {
                paths: [
                  '/api/mira/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'holidaycalendar-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/holidaycalendar-related-apis'
              properties: {
                paths: [
                  '/api/holidaycalendar/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'aiolos-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/aiolos-related-apis'
              properties: {
                paths: [
                  '/api/aiolos-usip/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'hive-related-api'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/hive-related-api'
              properties: {
                paths: [
                  '/api/thehive/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Apple-Developer-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/Apple-Developer-related-apis'
              properties: {
                paths: [
                  '/api/appstoreconnect/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'FUSE-EDGE-NBR'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/FUSE-EDGE-NBR'
              properties: {
                paths: [
                  '/api/nbr/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'xkey'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/xkey'
              properties: {
                paths: [
                  '/api/xkey*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Digicision-Related-Apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/Digicision-Related-Apis'
              properties: {
                paths: [
                  '/api/digicision*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'cpi-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/cpi-related-apis'
              properties: {
                paths: [
                  '/api/cpi/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'opengama-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/opengama-apis'
              properties: {
                paths: [
                  '/api/opengamma/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Iam-related-Apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/Iam-related-Apis'
              properties: {
                paths: [
                  '/api/iam/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'servicenow'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/servicenow'
              properties: {
                paths: [
                  '/api/servicenow-tableapi/*'
                  '/api/servicenow-attachment/*'
                  '/api/servicenow-catalog/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Rest-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/Rest-related-apis'
              properties: {
                paths: [
                  '/api/rest-proxy/*'
                  '/api/rest-proxy-tenoris/*'
                  '/api/rest-proxy-celonis/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'pkfg'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/pkfg'
              properties: {
                paths: [
                  '/api/pkfg-productconfiguration/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'fuse'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/fuse'
              properties: {
                paths: [
                  '/api/fuse-sharp-nip/*'
                  '/api/fuseihub/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'enmacc-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/enmacc-apis'
              properties: {
                paths: [
                  '/api/sales-trading-portal-enmacc-demand/*'
                  '/api/enmacc-connect/*'
                  '/api/enmacc-service-read/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'SOS-BERLIN-JOB-REPORTING'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/SOS-BERLIN-JOB-REPORTING'
              properties: {
                paths: [
                  '/api/sos-berlin-reporting/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'Demo-Open-AI'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/Demo-Open-AI'
              properties: {
                paths: [
                  '/api/openai/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'sap-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/sap-related-apis'
              properties: {
                paths: [
                  '/api/sapisu-forecast/*'
                  '/api/sap-supplier-notification/*'
                  '/api/sap-ice/*'
                  '/api/sap-sales-contract/*'
                  '/api/sap-ntwk-actvt-stat-chg/*'
                  '/api/sap-wbs-element-stat-chg/*'
                  '/api/sap-cats-wbs-employee/*'
                  '/api/sap-wbs/*'
                  '/api/sap-exchange-rate/*'
                  '/api/sap-my-quotation/*'
                  '/api/sap-zebi-billing/*'
                  '/api/sapisu-x63-idoc*'
                  '/api/sap-lmra/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'eai-usip-v10'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/eai-usip-v10'
              properties: {
                paths: [
                  '/api/eai-usip/*'
                  '/api/usip-confluent-utilities/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'seeburgeras4-related-apis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/seeburgeras4-related-apis'
              properties: {
                paths: [
                  '/api/seeburgeras4-neon/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'mdm-related-api'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/mdm-related-api'
              properties: {
                paths: [
                  '/api/mdmwebservice/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'myidentity'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/myidentity'
              properties: {
                paths: [
                  '/api/myidentity-b2cservice/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'pegasus'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/pegasus'
              properties: {
                paths: [
                  '/api/pegasus-*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'api-mia'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/api-mia'
              properties: {
                paths: [
                  '/api/mia-*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'UMS-related-APIs'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/UMS-related-APIs'
              properties: {
                paths: [
                  '/api/ums-*'
                  '/api/ums/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'demo'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/demo'
              properties: {
                paths: [
                  '/demo/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'EAM-DEV'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/EAM-DEV'
              properties: {
                paths: [
                  '/api/eam*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'azure-maps'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/azure-maps'
              properties: {
                paths: [
                  '/api/maps*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'api-external'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/api-external'
              properties: {
                paths: [
                  '/api/ex/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
                rewriteRuleSet: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/rewriteRuleSets/Forwardclientcertrule'
                }
              }
            }
            {
              name: 'SWAPI'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/SWAPI'
              properties: {
                paths: [
                  '/swapi*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'salerportal-related-APis'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/salerportal-related-APis'
              properties: {
                paths: [
                  '/api/salesportal-*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'UES_API'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/UES_API'
              properties: {
                paths: [
                  '/api/ues-*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
            {
              name: 'MCP'
              id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001/pathRules/MCP'
              properties: {
                paths: [
                  '/demo-eam-mcp/*'
                  '/enterprise-architecture-management/*'
                ]
                backendAddressPool: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-gateway-bp-001'
                }
                backendHttpSettings: {
                  id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-gateway-HttpSettings-001'
                }
              }
            }
          ]
        }
      }
    ]
    requestRoutingRules: [
      {
        name: 'uniperapis-dev-mgmt-Rule-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/requestRoutingRules/uniperapis-dev-mgmt-Rule-001'
        properties: {
          ruleType: 'Basic'
          priority: 10
          httpListener: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-dev-mgmt-listener-001'
          }
          backendAddressPool: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-mgmt-bp-001'
          }
          backendHttpSettings: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-mgmt-HttpSettings-001'
          }
        }
      }
      {
        name: 'uniperapis-dev-portal-Rule-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/requestRoutingRules/uniperapis-dev-portal-Rule-001'
        properties: {
          ruleType: 'Basic'
          priority: 20
          httpListener: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-dev-portal-listener-001'
          }
          backendAddressPool: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-dev-portal-bp-001'
          }
          backendHttpSettings: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-dev-portal-HttpSettings-001'
          }
        }
      }
      {
        name: 'uniperapis-uat-portal-Rule-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/requestRoutingRules/uniperapis-uat-portal-Rule-001'
        properties: {
          ruleType: 'Basic'
          priority: 30
          httpListener: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-uat-portal-listener-001'
          }
          backendAddressPool: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-portal-bp-001'
          }
          backendHttpSettings: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-portal-HttpSettings-001'
          }
        }
      }
      {
        name: 'uniperapis-uat-mgmt-Rule-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/requestRoutingRules/uniperapis-uat-mgmt-Rule-001'
        properties: {
          ruleType: 'Basic'
          priority: 40
          httpListener: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-uat-mgmt-listener-001'
          }
          backendAddressPool: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/uniperapis-uat-mgmt-bp-001'
          }
          backendHttpSettings: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/uniperapis-uat-mgmt-HttpSettings-001'
          }
        }
      }
      {
        name: 'uniperapis-dev-gateway-pathbased-rule-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/requestRoutingRules/uniperapis-dev-gateway-pathbased-rule-001'
        properties: {
          ruleType: 'PathBasedRouting'
          priority: 50
          httpListener: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-dev-gateway-listener-001'
          }
          urlPathMap: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-dev-gateway-pathbased-rule-001'
          }
        }
      }
      {
        name: 'uniperapis-uat-gateway-pathbased-rule-001'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/requestRoutingRules/uniperapis-uat-gateway-pathbased-rule-001'
        properties: {
          ruleType: 'PathBasedRouting'
          priority: 60
          httpListener: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/uniperapis-uat-gateway-listener-001'
          }
          urlPathMap: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/urlPathMaps/uniperapis-uat-gateway-pathbased-rule-001'
          }
        }
      }
      {
        name: 'Test-Rule'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/requestRoutingRules/Test-Rule'
        properties: {
          ruleType: 'Basic'
          priority: 10010
          httpListener: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/httpListeners/test-listener'
          }
          backendAddressPool: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendAddressPools/appGatewayBackendPool'
          }
          backendHttpSettings: {
            id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/backendHttpSettingsCollection/test-http'
          }
        }
      }
    ]
    routingRules: []
    probes: [
      {
        name: 'uniperapis-uat-gateway-probe-01'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-uat-gateway-probe-01'
        properties: {
          protocol: 'Https'
          path: '/status-0123456789abcdef'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'uniperapis-uat-portal-probe-01'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-uat-portal-probe-01'
        properties: {
          protocol: 'Https'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'uniperapis-uat-mgmt-probe-01'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-uat-mgmt-probe-01'
        properties: {
          protocol: 'Https'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            body: 'MissingOrIncorrectVersionParameter'
            statusCodes: [
              '200-400'
            ]
          }
        }
      }
      {
        name: 'uniperapis-dev-gateway-probe-01'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-dev-gateway-probe-01'
        properties: {
          protocol: 'Https'
          path: '/status-0123456789abcdef'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'uniperapis-dev-portal-probe-01'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-dev-portal-probe-01'
        properties: {
          protocol: 'Https'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            statusCodes: [
              '200-399'
            ]
          }
        }
      }
      {
        name: 'uniperapis-dev-mgmt-probe-01'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/probes/uniperapis-dev-mgmt-probe-01'
        properties: {
          protocol: 'Https'
          path: '/'
          interval: 30
          timeout: 30
          unhealthyThreshold: 3
          pickHostNameFromBackendHttpSettings: true
          minServers: 0
          match: {
            body: 'MissingOrIncorrectVersionParameter'
            statusCodes: [
              '200-400'
            ]
          }
        }
      }
    ]
    rewriteRuleSets: [
      {
        name: 'Forwardclientcertrule'
        id: '${applicationGateways_hub_uni_apim_npd_appgwv2_001_name_resource.id}/rewriteRuleSets/Forwardclientcertrule'
        properties: {
          rewriteRules: [
            {
              ruleSequence: 100
              conditions: []
              name: 'Forwardclientcertrule'
              actionSet: {
                requestHeaderConfigurations: [
                  {
                    headerName: 'X-Client-Cert'
                    headerValue: '{var_client_certificate}'
                  }
                  {
                    headerName: 'X-Client-Cert-Verification'
                    headerValue: '{var_client_certificate_verification}'
                  }
                  {
                    headerName: 'X-Client-Cert-Fingerprint'
                    headerValue: '{var_client_certificate_fingerprint}'
                  }
                ]
                responseHeaderConfigurations: []
              }
            }
          ]
        }
      }
    ]
    redirectConfigurations: []
    privateLinkConfigurations: []
    sslPolicy: {
      policyType: 'Custom'
      minProtocolVersion: 'TLSv1_2'
      cipherSuites: [
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384'
        'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256'
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
      ]
    }
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Prevention'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.1'
      disabledRuleGroups: [
        {
          ruleGroupName: 'General'
        }
        {
          ruleGroupName: 'REQUEST-920-PROTOCOL-ENFORCEMENT'
          rules: [
            920300
            920340
            920320
            920341
          ]
        }
        {
          ruleGroupName: 'REQUEST-942-APPLICATION-ATTACK-SQLI'
          rules: [
            942110
            942130
            942200
            942330
            942120
            942260
            942300
            942370
            942430
            942440
            942360
          ]
        }
        {
          ruleGroupName: 'REQUEST-911-METHOD-ENFORCEMENT'
        }
        {
          ruleGroupName: 'REQUEST-941-APPLICATION-ATTACK-XSS'
          rules: [
            941120
          ]
        }
      ]
      exclusions: [
        {
          matchVariable: 'RequestHeaderNames'
          selectorMatchOperator: 'Contains'
          selector: 'Content-Type'
        }
      ]
      requestBodyCheck: false
      maxRequestBodySizeInKb: 128
      fileUploadLimitInMb: 100
    }
    enableHttp2: false
    autoscaleConfiguration: {
      minCapacity: 1
      maxCapacity: 5
    }
    customErrorConfigurations: []
  }
}
