# Bitbucket-to-Kubernetes-Deployment

Bitbucket to Kubernetes Deployment.
# Step 1:
Push Code To Bitbucket:
Push code to the bitbucket repository.
Create Namespace in Kubernetes.
During the code push we need the following additional files.
    a) bitbucket-pipelines.yml
    b) Dockerfile
    c) Deployment.yaml
    d) Service.yaml
    e) Ingress.yaml
These above mentioned file are configure below.    

# Step 2:
bitbucket-pipelines.yml file Sample:
######
image: atlassian/pipelines-awscli

pipelines:
  branches:
    dev:
      - step:
          name: Push to ECR
          script: 
            - aws ecr get-login-password --region us-east-2 | docker login --username AWS --password-stdin ********.dkr.ecr.us-east-2.amazonaws.com
            - docker build -t $DOCKER_REGISTRY:latest .
            - docker push $DOCKER_REGISTRY:latest
       - step:
          name: Deployment in Kubernetes
          script:
            - pipe: atlassian/aws-eks-kubectl-run:1.2.0
              variables:
                AWS_ACCESS_KEY_ID: ${AWS_ACCESS_KEY_ID}
                AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY}
                AWS_DEFAULT_REGION: "REGION"
                CLUSTER_NAME: "CLUSTER_NAME"
                KUBECTL_COMMAND: "apply"
                #KUBECTL_COMMAND: "rollout restart deployment DEPLOYMENT_NAME -n NAMESPACE_NAME"
                RESOURCE_PATH: "LOACATION_OF_Deployment.yaml"
                DEBUG: "true"
#####

Dockerfile Sample:
FROM openjdk:11
WORKDIR /app
COPY MyApp.jar /app
CMD ["java", "-jar", "MyApp.jar"]

#######
Deployment.yaml Sample:
#########

apiVersion: apps/v1
kind: Deployment
metadata:
  name: APP_NAME
  namespace: NAMESPACE_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      app: APP_NAME
  template:
    metadata:
      labels:
        app: APP_NAME
    spec:
      containers:
        - name: CONTAINER_NAME
          image: IMAGE_URL
          imagePullPolicy: Always
          ports:
            - containerPort: CONTAINER_PORT
              protocol: TCP          

######              
Service.yaml Sample:
#####


apiVersion: v1
kind: Service
metadata:
  name: APP_NAME
  namespace: NAMESPACE_NAME
spec:
  selector:
    app: APP_NAME
  ports:
    - protocol: TCP
      port: PORT
      targetPort: TARGETPORT


 #####     
Ingress.yaml Sample:
#####


apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: APP_NAME
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - http: HOST_PATH
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: SERVICE_NAME
            port:
              number: PORT
