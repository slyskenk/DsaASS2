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

function approveKPIs(string[] kpiIds) {
    var mutation = """
        mutation {
            approveKPIs(kpiIds: %s)
        }
    """;

    var formattedKpiIds = ["\"" + id + "\"" | id in kpiIds];
    var formattedMutation = mutation.format(formattedKpiIds.toString());

    graphql:Operation approveKPIsOperation = {
        query: formattedMutation
    };

    var response = client->execute(approveKPIsOperation);
    match response {
        graphql:Response successResponse => {
            io:println("KPIs approved");
        }
        graphql:ErrorResponse errorResponse => {
            io:println("Error approving KPIs: " + errorResponse.errorMessage);
        }
    }
}

function deleteKPI(string kpiId) {
    var mutation = """
        mutation {
            deleteKPI(kpiId: "%s")
        }
    """;

    var formattedMutation = mutation.format(kpiId);

    graphql:Operation deleteKPIOperation = {
        query: formattedMutation
    };

    var response = client->execute(deleteKPIOperation);
    match response {
        graphql:Response successResponse => {
            io:println("KPI deleted");
        }
        graphql:ErrorResponse errorResponse => {
            io:println("Error deleting KPI: " + errorResponse.errorMessage);
        }
    }
}

function updateKPI() {
    var mutation = """
        mutation {
            updateKPI(kpi: {
                id: "1",
                name: "Updated KPI",
                target: 100,
                score: 75,
                userId: "1"
            })
        }
    """;

    graphql:Operation updateKPIOperation = {
        query: mutation
    };

    var response = client->execute(updateKPIOperation);
    match response {
        graphql:Response successResponse => {
            io:println("KPI updated");
        }
        graphql:ErrorResponse errorResponse => {
            io:println("Error updating KPI: " + errorResponse.errorMessage);
        }
    }
}

function getKPIsBySupervisor(string supervisorId) {
    var query = """
        {
            getKPIsBySupervisor(supervisorId: "%s") {
                id
                name
                target
                score
                userId
            }
        }
    """;

    var formattedQuery = query.format(supervisorId);

    graphql:Operation getKPIsBySupervisorOperation = {
        query: formattedQuery
    };

    var response = client->execute(getKPIsBySupervisorOperation);
    match response {
        graphql:Response successResponse => {
            var kpis = successResponse.data.toArray();
            io:println("KPIs by Supervisor:");
            foreach var kpi in kpis {
                io:println(kpi.toString());
            }
        }
        graphql:ErrorResponse errorResponse => {
            io:println("Error getting KPIs by Supervisor: " + errorResponse.errorMessage);
        }
    }
}

function gradeKPI(string kpiId, int score) {
    var mutation = """
        mutation {
            gradeKPI(kpiId: "%s", score: %d)
        }
    """;

    var formattedMutation = mutation.format(kpiId, score);

    graphql:Operation gradeKPIOperation = {
        query: formattedMutation
    };

   

