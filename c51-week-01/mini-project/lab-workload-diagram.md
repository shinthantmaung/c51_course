```mermaid
%%{init: {'theme': 'dark'}}%%
flowchart TD
    %% Define Nodes
    User[User browser]
    LB[Load balancer / CDN edge]
    Admin["Admin (ops engineer)"]
    CICD[CI/CD pipeline]
    
    WebApp[Web app<br/>compute — IaaS or PaaS]
    
    Storage[(Object storage bucket<br/>file uploads)]
    DB[(Managed Postgres<br/>PaaS)]

    %% Define Flows (Edges)
    User -->|HTTPS| LB
    LB -->|HTTPS| WebApp
    
    Admin -->|console + IAM role| WebApp
    CICD -->|deploy credentials| WebApp
    
    WebApp -->|Signed upload URL| Storage
    WebApp -->|SQL over TLS| DB
    
    
    Admin -->|console + IAM role| DB
