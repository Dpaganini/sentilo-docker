# sentilo-core
Esse projeto docker executa os módulos relacionados a sentilo, como:
* redis
* MongoDB
* Agents 
* Sentilo Catalog Web
* Sentilo Server

Configurações relacionadas a sentilo 

## Multitenant

O multitenant já está habilitado via `JAVA_OPTS` no `docker-compose.yml` (`-Dsentilo.multitenant=true`). Porém, é necessário ativar os filtros no `web.xml` dentro do container sempre que ele for **recriado do zero**.

### Ativando os filtros no web.xml

**1. Copiar o arquivo para fora do container:**
```bash
docker cp sentilo-catalog-web:/usr/local/tomcat/webapps/sentilo-catalog-web/WEB-INF/web.xml ./web.xml
```

**2. Descomentar os quatro blocos abaixo no `web.xml` copiado:**

```xml
<!-- Definições de filtro -->
<filter>
    <filter-name>UrlRewriteFilter</filter-name>
    <filter-class>org.tuckey.web.filters.urlrewrite.UrlRewriteFilter</filter-class>
    <init-param>
        <param-name>logLevel</param-name>
        <param-value>slf4j</param-value>
    </init-param>
</filter>

<filter>
    <filter-name>tenantInterceptorFilter</filter-name>
    <filter-class>org.sentilo.web.catalog.web.TenantInterceptorFilter</filter-class>
</filter>

<!-- Mapeamentos de filtro -->
<filter-mapping>
    <filter-name>tenantInterceptorFilter</filter-name>
    <url-pattern>/*</url-pattern>
    <dispatcher>REQUEST</dispatcher>
</filter-mapping>

<filter-mapping>
    <filter-name>UrlRewriteFilter</filter-name>
    <url-pattern>/*</url-pattern>
    <dispatcher>REQUEST</dispatcher>
    <dispatcher>FORWARD</dispatcher>
</filter-mapping>
```

**3. Copiar o arquivo editado de volta e reiniciar o container:**
```bash
docker cp ./web.xml sentilo-catalog-web:/usr/local/tomcat/webapps/sentilo-catalog-web/WEB-INF/web.xml
docker restart sentilo-catalog-web
```

### Usuários e tenants

O usuário **sadmin** é o super-administrador — gerencia as organizações (tenants). Outros usuários, incluindo admins de tenant, fazem login pela rota da respectiva organização (ex: `/sentilo-catalog-web/{tenant}/login`).

O projeto já possui dois tenants pré-configurados: **toledo-pr** (padrão) e **vitoria-es**. Após inicializar o projeto, é necessário criar usuários ADMIN para ambos via **sadmin**.