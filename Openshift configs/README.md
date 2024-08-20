Pre-requisitos:
Tener el operador OpenShift Logging instalado.
https://docs.openshift.com/container-platform/4.12/observability/logging/cluster-logging-deploying.html
Tener permisos de superusiario RBAC

Paso 1: Loguearse como admin o usuario con permisos RBAC y cambiar al namespaces openshift-logging
<pre>
oc login --token=<your token>
oc project openshift-logging
</pre>

Paso 2: Crear una service account
<pre>
oc create sa openshift-collector
</pre>

Paso 3: Darle permisos de aplicación, infraestructura y auditoría
https://access.redhat.com/solutions/7069256
<pre>
oc create clusterrole collect-application-logs
oc create clusterrole collect-audit-logs
oc create clusterrole collect-infrastructure-logs

oc create clusterrolebinding collect-app-logs --clusterrole=collect-application-logs --serviceaccount openshift-logging:openshift-collector
oc create clusterrolebinding collect-infra-logs --clusterrole=collect-infrastructure-logs --serviceaccount openshift-logging:openshift-collector
oc create clusterrolebinding collect-audit-logs --clusterrole=collect-audit-logs --serviceaccount openshift-logging:openshift-collector
</pre>

Paso 4: Crear un secret llamado elasticsearch-password con el siguiente contenido
<pre>
kind: Secret
apiVersion: v1
metadata:
  name: elasticsearch-password
  namespace: openshift-logging
data:
  password: SzByckpnaS1GTmNQUFdMajhRekY=
  username: ZWxhc3RpYw==
type: Opaque
</pre>

Paso 5: Ir al operador OpenShift Logging con la opción "Todos los proyectos" marcada e instalar un ClusterLogForwarder y un ClusterLogging con el contenido de los archivos .yaml con el mismo nombre de este directorio