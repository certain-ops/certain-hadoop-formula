{% from 'hadoop/settings.sls' import hadoop with context -%}

{% set hadoop_nodes = salt['saltutil.runner'](
    'manage.up', tgt=hadoop.target, expr_form=hadoop.target_type
  )
-%}

{# This should return the same node every time, even after adding or removing
#  boxes.
#}
{% set name_node = hadoop_nodes[0] -%}
{% set resource_manager = hadoop_nodes[0] -%}

{% set ret = [] -%}
{% do ret.append(salt['sdb.set']('sdb://hadoop/name_node', name_node)) -%}
{% do ret.append(salt['sdb.set']('sdb://hadoop/resource_manager', resource_manager)) -%}

{% if False in ret -%}
hadoop_bootstrap_failed:
  test.configurable_test_state:
    - result: False
    - comment: 'Failed to configure the Hadoop NameNode and ResourceManager. Is SDB available?'
{% else -%}
hadoop_bootstrap_succeeded:
  test.configurable_test_state:
    - result: True
    - comment: |
        'Successfully configured the Hadoop NameNode and ResourceManager.'
        'NameNode: {}'.format(salt['sdb.get']('sdb://hadoop/name_node')
        'ResourceManager: {}'.format(salt['sdb.get']('sdb://hadoop/resource_manager')
{%- endif %}
