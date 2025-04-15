# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Create sample articles for testing
puts "Creating sample articles..."

# Clear existing articles
Article.destroy_all

articles = [
  {
    title: "Getting Started with Ruby on Rails",
    content: "Ruby on Rails is a web application framework written in Ruby. It is designed to make programming web applications easier by making assumptions about what every developer needs to get started. It allows you to write less code while accomplishing more than many other languages and frameworks.

Rails is opinionated software. It makes the assumption that there is a 'best' way to do things, and it's designed to encourage that way - and in some cases to discourage alternatives. If you learn 'The Rails Way' you'll probably discover a tremendous increase in productivity. If you persist in bringing old habits from other languages to your Rails development, and trying to use patterns you learned elsewhere, you may have a less happy experience."
  },
  {
    title: "Understanding JavaScript Promises",
    content: "JavaScript promises are a powerful way to handle asynchronous operations. A promise represents the eventual result of an asynchronous operation. The primary way of interaction with a promise is through its 'then' method, which registers callbacks to receive either a promise's eventual value or the reason why the promise cannot be fulfilled.

Promises have revolutionized asynchronous programming in JavaScript, making it much more manageable and avoiding the so-called 'callback hell' that plagued earlier JavaScript code. With the introduction of async/await syntax, working with promises has become even more straightforward."
  },
  {
    title: "Effective Database Indexing Strategies",
    content: "Database indexing is a crucial aspect of database optimization that can significantly improve query performance. An index is a data structure that improves the speed of data retrieval operations on a database table at the cost of additional writes and storage space.

There are several types of indexes, including single-column indexes, composite indexes, and covering indexes. Choosing the right indexing strategy depends on your specific use case, the types of queries you're running, and the overall workload of your database system.

Remember that while indexes speed up read operations, they can slow down write operations. Therefore, it's essential to strike a balance between read and write performance when designing your indexing strategy."
  },
  {
    title: "Introduction to Container Orchestration with Kubernetes",
    content: "Kubernetes, often abbreviated as K8s, is an open-source container orchestration system for automating application deployment, scaling, and management. It was originally designed by Google and is now maintained by the Cloud Native Computing Foundation.

Kubernetes works by grouping containers that make up an application into logical units for easy management and discovery. It provides a framework to run distributed systems resiliently, handling failover, scaling, and load balancing for your applications.

Some of the key features of Kubernetes include automatic bin packing, self-healing capabilities, horizontal scaling, and service discovery and load balancing. These features make it an ideal platform for hosting cloud-native applications that require rapid scaling and high availability."
  },
  {
    title: "The Fundamentals of Machine Learning",
    content: "Machine learning is a subfield of artificial intelligence that focuses on the development of algorithms and statistical models that enable computers to perform tasks without explicit instructions. Instead, they rely on patterns and inference.

The main types of machine learning are supervised learning, unsupervised learning, and reinforcement learning. Supervised learning involves training a model on labeled data, unsupervised learning involves finding patterns in unlabeled data, and reinforcement learning involves training agents to interact with their environment to maximize rewards.

The applications of machine learning are vast and include areas such as computer vision, natural language processing, recommendation systems, fraud detection, and autonomous vehicles. As data continues to grow in volume and complexity, the importance of machine learning in extracting value from this data will only increase."
  },
  {
    title: "Mastering Git Version Control",
    content: "Git is a distributed version control system that tracks changes in any set of computer files, usually used for coordinating work among programmers collaboratively developing source code during software development. Its goals include speed, data integrity, and support for distributed, non-linear workflows.

Unlike older centralized version control systems such as SVN and CVS, Git gives each developer a local copy of the entire development history, and changes are copied from one repository to another. These changes are imported as additional development branches, and can be merged in the same way as a locally developed branch.

Git's distributed nature and branching model make it particularly suited for modern development practices like continuous integration and continuous deployment (CI/CD). Understanding Git's concepts of staging, committing, branching, merging, and rebasing is essential for any modern software developer."
  },
  {
    title: "The Art of Writing Clean Code",
    content: "Clean code is code that is easy to understand, easy to change, and easy to maintain. Writing clean code is a skill that takes time and practice to develop, but it's a skill that can greatly improve your effectiveness as a programmer.

Some principles of clean code include:
- Meaningful names: Use descriptive names for variables, functions, and classes.
- Small functions: Keep functions small and focused on a single task.
- DRY (Don't Repeat Yourself): Avoid duplication by abstracting common functionality.
- Comments: Write comments only when necessary, and make them meaningful.
- Error handling: Handle errors gracefully and informatively.

Remember, code is read much more often than it is written. Investing time in making your code clean and maintainable will pay dividends in the long run, both for yourself and for other developers who work with your code."
  },
  {
    title: "Understanding RESTful API Design",
    content: "RESTful API design is an architectural style for designing networked applications. REST, which stands for Representational State Transfer, relies on a stateless, client-server, cacheable communications protocol -- in virtually all cases, the HTTP protocol.

RESTful APIs are designed around resources, which are any kind of object, data, or service that can be accessed by the client. A resource has an identifier, which is a URI that uniquely identifies that resource.

The key principles of RESTful API design include:
- Client-server architecture: Separating the user interface concerns from data storage concerns.
- Statelessness: Each request from client to server must contain all the information needed to understand and complete the request.
- Cacheability: Responses must define themselves as cacheable or non-cacheable.
- Layered system: A client cannot ordinarily tell whether it is connected directly to the end server or to an intermediary along the way.
- Uniform interface: The method of communication between client and server must be uniform.

By following RESTful principles, you can design APIs that are intuitive, easy to use, and scalable."
  },
  {
    title: "The Importance of Cybersecurity in Modern Systems",
    content: "Cybersecurity refers to the practice of protecting systems, networks, and programs from digital attacks. These attacks are usually aimed at accessing, changing, or destroying sensitive information; extorting money from users; or interrupting normal business processes.

Implementing effective cybersecurity measures is particularly challenging today because there are more devices than people, and attackers are becoming more innovative. The key areas of cybersecurity include application security, information security, network security, disaster recovery, and end-user education.

Some best practices for cybersecurity include:
- Keeping software up to date
- Using strong, unique passwords and multi-factor authentication
- Being cautious with suspicious emails and links
- Regularly backing up your data
- Implementing robust security policies and procedures

Remember, cybersecurity is not just a technical issue but also a people issue. Education and awareness are just as important as technical measures in maintaining a strong security posture."
  },
  {
    title: "Introduction to Blockchain Technology",
    content: "Blockchain technology is a structure that stores transactional records, also known as blocks, of the public in several databases, known as the 'chain,' in a network connected through peer-to-peer nodes. Typically, this storage is referred to as a 'digital ledger.'

The digital ledger is like a Google spreadsheet shared across numerous computers in a network, in which transactional records are stored based on actual purchases. The fascinating angle is that anybody can see the data, but they can't corrupt it.

Blockchain technology was first outlined in 1991 by Stuart Haber and W. Scott Stornetta, two researchers who wanted to implement a system where document timestamps could not be tampered with. But it wasn't until almost two decades later, with the launch of Bitcoin in January 2009, that blockchain had its first real-world application.

The blockchain is used for the secure transfer of items like money, property, contracts, etc. without requiring a third-party intermediary like bank or government. Once a data is recorded inside a blockchain, it becomes very difficult to change it."
  }
]

articles.each do |article_data|
  Article.create!(article_data)
end

puts "Created #{Article.count} articles"
