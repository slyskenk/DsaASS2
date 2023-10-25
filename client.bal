import ballerina/http;
import ballerina/graphql;

// Define the GraphQL client configuration.
graphql:ClientConfiguration clientConfig = {
    endpointUrl: "http://localhost:4000/graphql", // Replace with the actual endpoint URL
    headers: {},
    timeout: 60000
};

// Create a GraphQL client.
graphql:Client client = new(clientConfig);

function main(string... args) {
    // Example calls to the GraphQL service

    // Create an Objective
    createObjective();

    // Delete an Objective
    deleteObjective("1");

    // Assign Supervisor
    assignSupervisor("1", "2");

    // Approve KPIs
    approveKPIs(["1", "2"]);

    // Delete KPI
    deleteKPI("1");

    // Update KPI
    updateKPI();

    // Get KPIs by Supervisor
    getKPIsBySupervisor("2");

    // Grade KPI
    gradeKPI("1", 90);

    // Create KPI
    createKPI();

    // Get Total Score
    getScore("1");

    // Grade Supervisor
    gradeSupervisor("2", 95);
}

function createObjective() {
    var mutation = """
        mutation {
            createObjective(objective: {
                name: "New Objective",
                percentage: 80
            })
        }
    """;

    graphql:Operation createObjectiveOperation = {
        query: mutation
    };

    var response = client->execute(createObjectiveOperation);
    match response {
        graphql:Response successResponse => {
            io:println("Objective created with ID: " + successResponse.data.toString());
        }
        graphql:ErrorResponse errorResponse => {
            io:println("Error creating objective: " + errorResponse.errorMessage);
        }
    }
}

function deleteObjective(string objectiveId) {
    var mutation = """
        mutation {
            deleteObjective(objectiveId: "%s")
        }
    """;

    var formattedMutation = mutation.format(objectiveId);

    graphql:Operation deleteObjectiveOperation = {
        query: formattedMutation
    };

    var response = client->execute(deleteObjectiveOperation);
    match response {
        graphql:Response successResponse => {
            io:println("Objective deleted: " + successResponse.data.toString());
        }
        graphql:ErrorResponse errorResponse => {
            io:println("Error deleting objective: " + errorResponse.errorMessage);
        }
    }
}

function assignSupervisor(string userId, string supervisorId) {
    var mutation = """
        mutation {
            assignSupervisor(userId: "%s", supervisorId: "%s")
        }
    """;

    var formattedMutation = mutation.format(userId, supervisorId);

    graphql:Operation assignSupervisorOperation = {
        query: formattedMutation
    };

    var response = client->execute(assignSupervisorOperation);
    match response {
        graphql:Response successResponse => {
            io:println("Supervisor assigned");
        }
        graphql:ErrorResponse errorResponse => {
            io:println("Error assigning supervisor: " + errorResponse.errorMessage);
        }
    }
}

