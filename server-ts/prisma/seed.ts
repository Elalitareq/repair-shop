import { PrismaClient } from "@prisma/client";
import bcrypt from "bcrypt";

const prisma = new PrismaClient();

async function main() {
  console.log("🌱 Seeding database...");

  // Check if data already exists
  const userCount = await prisma.user.count();
  if (userCount > 0) {
    console.log("✅ Database already seeded");
    return;
  }

  // Seed Conditions
  const conditions = [
    { name: "New", description: "Brand new, unused" },
    { name: "Like New", description: "Minimal signs of use" },
    { name: "Good", description: "Normal wear and tear" },
    { name: "Fair", description: "Noticeable wear" },
    { name: "Poor", description: "Significant damage" },
  ];

  for (const condition of conditions) {
    await prisma.condition.create({ data: condition });
  }
  console.log("✅ Conditions seeded");

  // Seed Qualities
  const qualities = [
    { name: "Original", description: "Original parts and condition" },
    { name: "AAA", description: "High quality aftermarket" },
    { name: "High Copy", description: "Good quality copy" },
    { name: "Copy", description: "Standard copy quality" },
  ];

  for (const quality of qualities) {
    await prisma.quality.create({ data: quality });
  }
  console.log("✅ Qualities seeded");

  // Seed Repair States
  const repairStates = [
    { name: "Received", description: "Repair received", order: 1 },
    { name: "Diagnosed", description: "Issue diagnosed", order: 2 },
    { name: "In Progress", description: "Being repaired", order: 3 },
    { name: "Waiting Parts", description: "Waiting for parts", order: 4 },
    { name: "Completed", description: "Repair completed", order: 5 },
    { name: "Ready for Pickup", description: "Ready for customer", order: 6 },
    { name: "Delivered", description: "Delivered to customer", order: 7 },
  ];

  for (const state of repairStates) {
    await prisma.repairState.create({ data: state });
  }
  console.log("✅ Repair states seeded");

  // Seed Issue Types
  const issueTypes = [
    { name: "Screen Damage", description: "Cracked or broken screen" },
    {
      name: "Battery Issue",
      description: "Battery not charging or draining fast",
    },
    { name: "Water Damage", description: "Device exposed to liquid" },
    { name: "Camera Issue", description: "Camera not working properly" },
    { name: "Speaker/Microphone", description: "Audio issues" },
    { name: "Charging Port", description: "Charging port problems" },
    { name: "Software Issue", description: "Software or OS problems" },
    { name: "Other", description: "Other issues" },
  ];

  for (const issueType of issueTypes) {
    await prisma.issueType.create({ data: issueType });
  }
  console.log("✅ Issue types seeded");

  // Seed Payment Methods
  const paymentMethods = [
    { name: "Cash", description: "Cash payment", feeRate: 0.0 },
    {
      name: "Whish Money",
      description: "Whish money (wallet) payment",
      feeRate: 0.0,
    },
    
  ];

  for (const method of paymentMethods) {
    await prisma.paymentMethod.create({ data: method });
  }
  console.log("✅ Payment methods seeded");

  // Create default admin user
  const hashedPassword = await bcrypt.hash("myshop99", 10);
  const tech1HashedPassword = await bcrypt.hash("66897197aA@", 10);
  await prisma.user.create({
    data: {
      username: "khaled",
      email: "khaled@repairshop.com",
      password: hashedPassword,
      role: "admin",
    },
  });

  await prisma.user.create({
    data: {
      username: "admin",
      email: "tech1@repairshop.com",
      password: tech1HashedPassword,
      role: "admin",
    },
  });

  console.log("✅ Admin user created (username: khaled, password: myshop99)");

  // Seed demo customer
  const demoCustomer = await prisma.customer.create({
    data: {
      name: "John Doe",
      phone: "+1234567890",
      email: "john.doe@example.com",
      address: "123 Main St, City, Country",
    },
  });
  console.log("✅ Demo customer created");


  console.log("🎉 Database seeding completed!");

  // Add demo serials (IMEIs) if items and batches exist

}

main()
  .catch((e) => {
    console.error("❌ Error seeding database:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
