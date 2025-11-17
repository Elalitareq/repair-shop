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
    { name: "Card", description: "Credit/Debit card", feeRate: 0.025 },
    { name: "Bank Transfer", description: "Bank transfer", feeRate: 0.0 },
    {
      name: "Mobile Payment",
      description: "Mobile payment apps",
      feeRate: 0.015,
    },
  ];

  for (const method of paymentMethods) {
    await prisma.paymentMethod.create({ data: method });
  }
  console.log("✅ Payment methods seeded");

  // Create default admin user
  const hashedPassword = await bcrypt.hash("admin123", 10);
  await prisma.user.create({
    data: {
      username: "admin",
      email: "admin@repairshop.com",
      password: hashedPassword,
      role: "admin",
    },
  });
  console.log("✅ Admin user created (username: admin, password: admin123)");

  console.log("🎉 Database seeding completed!");
}

main()
  .catch((e) => {
    console.error("❌ Error seeding database:", e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
