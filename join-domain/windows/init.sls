{%- set join_domain = salt['pillar.get']('join-domain:windows', {}) %}

{%- if join_domain.oupath %}

join standalone system to domain in specified ou:
  cmd.run:
    - name: '
      try
      {
        $domain = ([System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()).Name;
        "changed=no comment=`"System is joined already to a domain [$domain].`" domain=$domain";
      }
      catch
      {
        $cred = New-Object -TypeName System.Management.Automation.PSCredential
          -ArgumentList {{ join_domain.username }}, (ConvertTo-SecureString 
          -String {{ join_domain.encrypted_password }} 
          -Key ([Byte[]] "{{ join_domain.key }}".split(",")));
        Add-Computer -DomainName {{ join_domain.domain_name }} -Credential $cred
          -Force -OUPath {{ join_domain.oupath }} -ErrorAction Stop;
        "changed=yes comment=`"Joined system to the domain.`" domain={{ join_domain.domain_name }}"
      }'
    - shell: powershell
    - stateful: true

{%- elif join_domain %}

join standalone system to domain in default ou:
  cmd.run:
    - name: '
      try
      {
        $domain = ([System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()).Name;
        "changed=no comment=`"System is joined already to a domain [$domain].`" domain=$domain";
      }
      catch
      {
        $cred = New-Object -TypeName System.Management.Automation.PSCredential
          -ArgumentList {{ join_domain.username }}, (ConvertTo-SecureString 
          -String {{ join_domain.encrypted_password }} 
          -Key ([Byte[]] "{{ join_domain.key }}".split(",")));
        Add-Computer -DomainName {{ join_domain.domain_name }} -Credential $cred
          -Force -ErrorAction Stop;
        "changed=yes comment=`"Joined system to the domain.`" domain={{ join_domain.domain_name }}"
      }'
    - shell: powershell
    - stateful: true
{%- endif %}
