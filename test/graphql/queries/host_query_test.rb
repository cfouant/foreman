require 'test_helper'

class Queries::HostQueryTest < GraphQLQueryTestCase
  let(:query) do
    <<-GRAPHQL
      query (
        $id: String!
      ) {
        host(id: $id) {
          id
          createdAt
          updatedAt
          name
          build
          ip
          ip6
          path
          mac
          lastReport
          domainName
          pxeLoader
          enabled
          uuid
          environment {
            id
          }
          computeResource {
            id
          }
          architecture {
            id
          }
          domain {
            id
          }
          location {
            id
          }
          model {
            id
          }
          operatingsystem {
            id
          }
          puppetCaProxy {
            id
          }
          puppetProxy {
            id
          }
          factNames {
            totalCount
            edges {
              node {
                id
              }
            }
          }
          factValues {
            totalCount
            edges {
              node {
                id
              }
            }
          }
        }
      }
    GRAPHQL
  end

  let(:hostgroup) { FactoryBot.create(:hostgroup, :with_compute_resource) }
  let(:host) do
    FactoryBot.create(:host, :managed,
                             :with_environment,
                             :with_model,
                             :with_facts,
                             :with_puppet,
                             :with_puppet_ca,
                             hostgroup: hostgroup,
                             uuid: Foreman.uuid,
                             last_report: Time.now)
  end
  let(:global_id) { Foreman::GlobalId.encode('Host', host.id) }
  let(:variables) { { id: Foreman::GlobalId.encode('Host', host.id) } }
  let(:data) { result['data']['host'] }

  test 'fetching host attributes' do
    assert_empty result['errors']
    assert_equal global_id, data['id']
    assert_equal host.created_at.utc.iso8601, data['createdAt']
    assert_equal host.updated_at.utc.iso8601, data['updatedAt']
    assert_equal host.name, data['name']
    assert_equal host.build, data['build']
    assert_equal host.ip, data['ip']
    assert_equal host.ip6, data['ip6']
    assert_equal Rails.application.routes.url_helpers.host_path(host), data['path']
    assert_equal host.mac, data['mac']
    assert_equal host.last_report.utc.iso8601, data['lastReport']
    assert_equal host.domain_name, data['domainName']
    assert_equal host.pxe_loader, data['pxeLoader']
    assert_equal host.enabled, data['enabled']
    assert_equal host.uuid, data['uuid']

    assert_record host.environment, data['environment']
    assert_record host.compute_resource, data['computeResource'], type_name: 'ComputeResource'
    assert_record host.architecture, data['architecture']
    assert_record host.domain, data['domain']
    assert_record host.location, data['location']
    assert_record host.model, data['model']
    assert_record host.operatingsystem, data['operatingsystem']
    assert_record host.puppet_ca_proxy, data['puppetCaProxy']
    assert_record host.puppet_proxy, data['puppetProxy']

    assert_collection host.fact_names, data['factNames']
    assert_collection host.fact_values, data['factValues']
  end
end
